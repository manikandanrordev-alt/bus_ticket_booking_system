# Bus Ticket Booking System

A Ruby on Rails bus ticket booking application demonstrating trip search, seat selection, temporary seat holds, booking confirmation, cancellation, and rescheduling with PostgreSQL-backed concurrency control.

## Features

### Authentication

- Email-only signup and login
- Session-based authentication
- Logout
- Authenticated access to booking features

### Trip Search

Search trips by:

- From city
- To city
- Travel date

Advanced filters:

- Operator rating
- Price range
- Bus type
  - AC
  - Non-AC
- Seat type
  - Seater
  - Sleeper
- Amenities
  - Wi-Fi
  - Charging Point
  - Water Bottle
  - Blanket

Trip search results are cached using `Rails.cache`.

### Seat Selection and Temporary Hold

- Select one or more available seats.
- Selected seats are held for 5 minutes.
- Held seats cannot be selected by another user.
- Expired holds automatically release their seats.
- Invalid or unavailable seat selections are rejected.

### Booking Confirmation

- Active holds can be converted into bookings.
- Booking confirmation runs inside a database transaction.
- Idempotency keys prevent duplicate bookings.
- A unique database index provides an additional duplicate protection layer.
- Concurrent duplicate requests return the existing booking.

### Booking Cancellation

Bookings can be cancelled only when departure is more than 1 hour away.

Refund calculation:

```text
Refund = Ticket Amount - ₹50 cancellation fee