# TicketHub Design

## 1. Requirements

### Functional
- Browse and search events.
- View an event’s seats and availability.
- Temporarily hold available seats.
- Pay for a held order and receive tickets.
- View a user’s orders and tickets.

### Non-functional
- **Speed:** Event browsing should be fast under normal and sale traffic; seat availability and hold results should respond promptly.
- **Correctness:** A seat must never be sold to more than one customer. Payment and order state must remain consistent, including after retries or failures.
- **Fairness:** Apply per-user and per-event purchase limits, rate limits, and a fair, observable queue during exceptionally popular sales. Do not let clients bypass the queue by repeatedly refreshing.
- **Availability and durability:** Keep browsing available during surges, and persist confirmed orders and payment outcomes.
- **Security:** Authenticate users and protect payment and personal information.

## 2. Estimates

Assume a 24-hour day. Normal-day page views are spread evenly across the day; big-sale attempts are spread evenly across the stated 10-minute window. A page view is an application request, not necessarily one HTTP request.

### Normal traffic
- Registered users: 2 million.
- Daily visitors: 50,000.
- Page views: 50,000 × 10 = **500,000/day**, or about **5.8 page views/second** on average.
- Tickets sold: **5,000/day**, or about **0.058 tickets/second** on average.

### Popular concert sale
- Buyers attempting to purchase: **200,000 in 10 minutes** = about **333 purchase attempts/second**.
- Seats available: **20,000**.
- Demand is **10× supply**; at most 10% of attempting buyers can get a seat.
- The sale’s attempt rate is about **57× the normal average page-view rate**, though these are different request types. Browsing, seat-map refreshes, retries, and payment calls can make actual API traffic higher than 333 requests/second.

Use load testing and live metrics to size capacity; the estimate is a starting point, not a guarantee.

## 3. API

All endpoints require authentication where appropriate. Use idempotency keys for hold and payment requests so retries do not create duplicate orders or charges.

| Method and endpoint | Purpose |
|---|---|
| `GET /events?query=&date=` | Browse and search events |
| `GET /events/{eventId}` | View event details |
| `GET /events/{eventId}/seats` | View seat map and availability |
| `POST /events/{eventId}/holds` | Request a temporary hold for selected seat IDs |
| `POST /orders/{orderId}/pay` | Pay for a held order |
| `GET /me/tickets` | View the authenticated user’s tickets |
| `GET /me/orders/{orderId}` | View order status and details |

The hold endpoint returns the held seats, order ID, and hold-expiration time; it returns a conflict if any requested seat is no longer available.

## 4. Data model

- **Users** (`id` PK, `email` UNIQUE, `created_at`)
- **Events** (`id` PK, `name`, `venue`, `starts_at`, `status`)
- **Seats** (`id` PK, `event_id` FK → Events, `section`, `row`, `seat_number`, `status`, `held_by_user_id` FK → Users nullable, `hold_expires_at` nullable)
  - Add `UNIQUE(event_id, section, row, seat_number)` so a seat location exists only once per event.
- **Orders** (`id` PK, `user_id` FK → Users, `event_id` FK → Events, `status`, `idempotency_key`, `created_at`, `hold_expires_at`, `payment_reference` nullable)
  - Add `UNIQUE(user_id, idempotency_key)` to make order creation safe to retry.
- **OrderSeats** (`order_id` FK → Orders, `seat_id` FK → Seats, PK `(order_id, seat_id)`, `UNIQUE(seat_id)`)
  - Links orders to seats and ensures a seat can belong to at most one order.

An event has many seats; a user can have many orders; an order can contain multiple seats. `OrderSeats` connects orders and seats.

## 5. Architecture

```text
Users
  |
CDN / WAF / rate limiter
  |
Load balancer
  |
Application servers ---- Queue ---- Workers (email, cleanup, other async jobs)
  |                         |
  |                         +---- Payment provider (payment processing is initiated
  |                               by the application; callbacks update order status)
  |
  +---- Cache (event details, non-authoritative seat-map snapshots)
  |
  +---- Database primary (transactions, seat holds, orders)
            |
            +---- Read replicas (event browsing and other safe reads)
            