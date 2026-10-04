
`day8/reflection.md` (150–300 words)
```markdown
The most difficult concept in the course was designing for correctness when requests happen concurrently. It was easy to describe a seat as “available,” but harder to see why checking availability in the application and then updating it is unsafe: two requests can pass the check at nearly the same time. I worked through this by tracing competing requests step by step and making the database transaction and uniqueness constraint—not the cache—the final authority. That helped me understand how transactions and constraints work together.

Based on the feedback I received on my capstone, I would improve the explanation of how the system behaves under failure. I would add clearer examples for retries, delayed payment confirmations, and recovery after a worker or service is unavailable. I would also make the capacity assumptions more explicit and distinguish average traffic from short-lived peaks, so the scaling choices are easier to evaluate.

Next, I want to learn more about database isolation levels and how to test concurrency safely. I would also like to study observability: choosing useful metrics, tracing a request across services, and using load tests to find bottlenecks before launch. Those skills would help me turn a high-level design into a system whose correctness and performance can be verified rather than assumed.