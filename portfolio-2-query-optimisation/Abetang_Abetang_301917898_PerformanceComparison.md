# Query performance comparison

## Query tested

The query searched for scheduled journeys on route 1 between 1 March and 1 April 2028 using the 16,000 generated performance rows.

The same `EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)` query was executed three times before and three times after creating the portfolio indexes. Median values were used to reduce the effect of individual timing fluctuations.

## Index evaluated

```sql
CREATE INDEX IF NOT EXISTS idx_journeys_route_departure
    ON journeys (route_id, planned_departure)
    INCLUDE (service_number, planned_arrival, status, train_id);
```

## Recorded executions

| Stage | Run | Planning time (ms) | Execution time (ms) | Shared buffers hit/read |
|---|---:|---:|---:|---:|
| Before index | 1 | 1.144 | 1.860 | 80/0 |
| Before index | 2 | 6.401 | 7.992 | 75/0 |
| Before index | 3 | 0.137 | 1.224 | 75/0 |
| After index | 1 | 2.199 | 1.886 | 43/9 |
| After index | 2 | 0.222 | 0.921 | 46/0 |
| After index | 3 | 0.165 | 1.996 | 46/0 |

## Median performance comparison

| Measurement | Before portfolio index | After portfolio index | Interpretation |
|---|---:|---:|---|
| Scan type | Bitmap Heap Scan | Bitmap Heap Scan | Both plans used an index-assisted heap scan. |
| Index used | `uq_dated_service` | `idx_journeys_route_departure` | PostgreSQL selected the new composite index after it was created. |
| Estimated plan cost | 385.25–387.11 | 290.14–292.00 | The estimated upper cost decreased by approximately 24.6%. |
| Median execution time (ms) | 1.860 | 1.886 | The difference of 0.026 ms was negligible, so no reliable timing improvement was observed. |
| Median planning time (ms) | 1.144 | 0.222 | Median planning time was lower after indexing, although planning time can fluctuate. |
| Median shared buffers hit/read | 75/0 | 46/0 | Warm-cache buffer hits decreased by approximately 38.7%. |
| Rows returned | 744 | 744 | Both plans returned identical results. |
| Rows produced by index scan | 2,976 | 744 | The composite index located only the required route and date rows. |
| Rows removed by filtering | 2,232 | 0 | The new index avoided filtering journeys belonging to other routes. |
| Index searches | 9 | 1 | The composite index completed the lookup using one index search. |
| Heap blocks visited | 37 | 37 | The matching journeys occupied the same 37 table blocks. |
| Sorting | Quicksort, 59 kB | Quicksort, 59 kB | The `ORDER BY` operation was unchanged. |

## Analysis

Before the portfolio index was created, PostgreSQL used the existing `uq_dated_service` index to locate 2,976 journeys within the departure-date range. The Bitmap Heap Scan then removed 2,232 journeys that did not belong to route 1.

After creating `idx_journeys_route_departure`, PostgreSQL used the combined `(route_id, planned_departure)` columns to locate exactly the 744 required journeys. This reduced buffer hits, eliminated unnecessary filtering, reduced index searches from nine to one and lowered the estimated plan cost.

The median execution time remained effectively unchanged because the 16,000-row test dataset was relatively small and cached in memory. Nevertheless, the new index produced a more selective and resource-efficient execution plan. Its trade-offs are additional storage and maintenance work during inserts and updates.