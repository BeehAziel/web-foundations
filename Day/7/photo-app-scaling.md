# SnapShare Scaling Plan

## Assumptions and estimates

- SnapShare has 10 million registered users.
- 10% of registered users are active each day, so daily active users (DAU) are **1 million**.
- Each DAU uploads 1 photo and views 50 feed pages per day.
- A feed page request counts as one feed view; photo delivery may involve multiple image requests.
- An average original photo is 2 MB, and each photo gets one 50 KB thumbnail.
- Calculations use a 24-hour day and an average upload rate spread evenly across the day.
- Peak feed traffic is estimated at 5× the average.
- Storage estimates assume one copy of every original and thumbnail, with no replication, backups, or deletion.

| Metric | Calculation | Estimate |
|---|---:|---:|
| Uploads per day | 1,000,000 DAU × 1 | 1,000,000 |
| Average uploads per second | 1,000,000 ÷ 86,400 | **11.6/s** |
| Feed views per day | 1,000,000 DAU × 50 | 50,000,000 |
| Average feed views per second | 50,000,000 ÷ 86,400 | **579/s** |
| Peak feed views per second | 579 × 5 | **2,895/s** |
| Photo storage per year | 1,000,000 × 365 × (2 MB + 0.05 MB) | **748.25 TB/year** (decimal) |

SnapShare is **read-heavy**: there are about 50 feed views for every upload, and peak feed traffic is much higher than average upload traffic. The design should scale read paths with caching, read replicas, and a CDN, while keeping uploads durable and processing them asynchronously.

## Architecture

```text
                         +----------------------+
                         |        Users         |
                         +----------+-----------+
                                    |
                     +--------------+--------------+
                     |                             |
                Feed/API requests              Photo requests
                     |                             |
             +-------v--------+             +------v------+
             | Load balancer  |             |    CDN      |
             +-------+--------+             +------+------+
                     |                             |
             +-------v--------+                    |
             |  App servers  |                    |
             +---+--------+--+                    |
                 |        |                       |
        +--------v--+  +--v----------------+      |
        |   Cache   |  | Database (primary)|      |
        +-----------+  +--------+----------+      |
                                |                 |
                         +------v-------+         |
                         | Read replica |         |
                         +--------------+         |
                                                  |
                         +------------------------v--+
                         | Object storage: originals |
                         | and generated thumbnails  |
                         +---------------------------+

Upload processing:
App servers --> Object storage (original) --> Queue --> Thumbnail worker
                                                      |
                                                      +--> Object storage (thumbnail)


Why photos do not belong in the database
Photo files are large binary objects, so storing them in the database would inflate backups and database storage, increase the cost and complexity of scaling, and compete with metadata queries. Store the files in object storage and keep only their keys, URLs, and related metadata in the database.
Trade-offs

Asynchronous thumbnails improve upload speed but add delay: Users can finish uploading quickly, but a thumbnail may not be available until the queue and worker process the job.
Caching and CDN delivery improve read performance but can serve stale content: Cache invalidation and expiration policies are needed when photos or metadata change.