# Portfolio 4 - NoSQL and Advanced Data Models

## Selected model

MongoDB is used to implement a denormalized document-based ticket read model for fast QR-ticket lookup, booking-history display and ticket validation. It contains the booking reference, masked passenger identity, journey, boarding/destination stations, coach and seat, charged fare, QR token and a bounded validation summary.

This model suits station gates, mobile booking history and conductor lookup because all information required to display or verify one ticket is read together. PostgreSQL remains authoritative for payments and seat allocation because the exclusion constraint and transaction guarantees must not be weakened.

## Suitability of MongoDB

MongoDB's document model is suitable for the ticket read model because a ticket is normally retrieved and displayed as one complete unit. Embedding the passenger snapshot, journey, stations, coach, seat and fare removes the joins that would otherwise be required across several PostgreSQL tables. A unique index on `qr_token` supports direct QR validation, while an index on `booking_reference` supports a customer's booking-history lookup.

The document structure also accommodates a bounded array of validation events without requiring a separate join for every scan. Storing the issued values as a snapshot is useful because the ticket should continue to display the passenger, station, seat and fare information that applied when it was issued, even if the operational records later change.

MongoDB is not used as the authoritative booking database. Embedding duplicates some relational data, updates may be eventually consistent, and the model is not appropriate for enforcing payment integrity or preventing overlapping seat allocations. Those operations require PostgreSQL transactions, foreign keys and the seat-range exclusion constraint. MongoDB therefore complements PostgreSQL by providing a read-optimized representation rather than replacing the normalized transactional model.

## Embedding decision

Journey, passenger and seat values are embedded as an issued-ticket snapshot. If a station or coach name later changes, the ticket still shows what was issued. A small validation summary can also be embedded because its growth is bounded for an ordinary journey.

Unbounded audit events, all passengers on a train and the complete seat inventory should not be embedded in one ticket document. Those remain relational or belong in a separate event collection in a larger implementation.

## Synchronization

After the PostgreSQL transaction commits, an application worker upserts the MongoDB document. The read model is therefore eventually consistent and carries `source_version` and `synced_at`. Seat availability and ticket issuance always read/write PostgreSQL.

## Atlas implementation

The read model was implemented in MongoDB Atlas using:

- Database: `nrc_ticket_read`
- Collection: `ticket_documents`

Connected to the Atlas deployment using MongoDB Compass


## Evidence

| Evidence | Screenshot | What it demonstrates |
|---|---|---|
| Collection indexes | [View indexes](./Abetang_Abetang_301917898_Indexes.png) | Shows the automatic `_id_` index and the four indexes created for ticket lookup, booking history and journey queries. |
| QR-token lookup | [View QR lookup](./Abetang_Abetang_301917898_QRTokenLookup.png) | Shows that a ticket can be retrieved directly using its unique QR token. |
| Schema validation | [View schema validator](./Abetang_Abetang_301917898_SchemaValidation.png) | Shows the JSON Schema rules used to enforce the required ticket-document structure. |
| Ticket documents, part 1 | [View ticket documents 1](./Abetang_Abetang_301917898_TicketDocuments01.png) | Shows the embedded passenger, journey and seat information. |
| Ticket documents, part 2 | [View ticket documents 2](./Abetang_Abetang_301917898_TicketDocuments02.png) | Shows the remaining embedded fare, validation and synchronization information. |


