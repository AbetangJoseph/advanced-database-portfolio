# Portfolio 1 - Database Design and Modelling

## Chosen case study

This portfolio uses the Nigerian Railway Corporation passenger train reservation system as its case study. The system serves passengers, ticket agents, station staff, conductors and administrators. It stores users, stations, routes, trains, coaches, seats, journeys, fares, bookings, passengers, tickets and payments. Its main operations are journey search, passenger booking, coach and seat selection, payment recording, QR-ticket issuance and prevention of overlapping seat reservations.

## Relational database model

This section models the core entities and relationships of the Nigerian Railway reservation system. The ER diagram provides a visual overview of the database design: [ER Diagram](Abetang_Abetang_301917898_ER_Diagram.png)

| Table                | Purpose                                                                 |
| -------------------- | ----------------------------------------------------------------------- |
| `users`              | Passenger, agent, station staff, conductor and administrator accounts   |
| `stations`           | Lagos, Abeokuta, Ibadan and other passenger stations                    |
| `routes`             | Directional passenger routes such as Lagos to Ibadan                    |
| `route_stations`     | Ordered stations along each route                                       |
| `trains`             | Physical train sets                                                     |
| `coaches`            | Coaches attached to each train                                          |
| `seats`              | Numbered seats within each coach                                        |
| `journeys`           | A dated train service assigned to a route and train                     |
| `journey_stops`      | Planned/actual arrival and departure information for each stop          |
| `bookings`           | Booking reference, owner, sales channel, status and total               |
| `booking_passengers` | Travellers included in a booking                                        |
| `tickets`            | Passenger, journey, seat, boarding/destination stops, fare and QR token |
| `payments`           | Payment attempts and successful payments                                |
| `fares`              | Price by route, station pair, coach class and passenger type            |

## Relationships

- A route contains ordered stations through `route_stations`.
- A train contains coaches, and a coach contains numbered seats.
- A journey assigns one train to one route on a specific date.
- `journey_stops` records the operational timetable for that dated journey.
- A user owns bookings; each booking contains one or more passengers.
- A ticket connects one booking passenger to a journey, boarding stop, destination stop and seat.
- A booking may have multiple payment attempts, but only successful amounts count as paid.

## Constraints

- Unique email, station code, route code, train number, booking reference, ticket number, QR token and payment provider reference.
- Composite foreign keys prove that a ticket's passenger belongs to its booking and that its boarding and destination stops belong to its journey.
- A trigger rejects destinations that do not occur after the boarding stop.
- The same trigger verifies that the selected seat belongs to the train operating the journey.
- `tickets.occupied_range` is generated from stop sequences.
- A GiST exclusion constraint rejects overlapping `HELD`, `ISSUED` or `USED` tickets for the same journey and seat.
- Adjacent non-overlapping uses remain valid, so a seat can be sold again after the first passenger alights.

## Normalization

The PostgreSQL database is normalized to Third Normal Form (3NF), as explained below

- **1NF:** users, stations, stops, seats, passengers, tickets and payments are separate atomic rows.
- **2NF:** attributes in relationship tables depend on their full key. Stop order belongs to the route-station pair, while scheduled times belong to a dated journey stop.
- **3NF:** station information is not copied into routes or journeys; coach information is not copied into seats; account data are not copied into bookings; and payment attempts are independent of tickets.

The fare charged is copied to `tickets.charged_fare` intentionally. It is a historical transaction value that must remain unchanged if the public fare table later changes.
