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
```

## Technical Architecture & Requirements

### Concurrency & Locking
The system relies on PostgreSQL's pessimistic locking (`FOR UPDATE`) for concurrency control during seat holding and booking confirmation. This ensures that no two users can acquire a hold on the same seat simultaneously (no overselling), satisfying the strict single-user-per-seat-hold requirement.

### Background Jobs
ActiveJob (with Solid Queue configured for production) is utilized to automatically release seats if a hold is not confirmed within the 5-minute window (`ExpireHoldJob`).

### Architecture (Service Objects)
All complex business logic is strictly encapsulated within dedicated Service Objects (`app/services/`), such as `BookingConfirmationService`, `BookingCancellationService`, and `SeatHoldService`. This prevents fat models/controllers and makes the system modular.

### Performance & Cache Invalidation
Trip search results are heavily cached using `Rails.cache`. 
To ensure data accuracy, the cache key automatically includes `TripSeat.maximum(:updated_at)`. This means that whenever *any* seat is held, booked, or released, the cache is instantly and explicitly busted, ensuring users always see real-time seat availability.

### Testing
Critical business paths are thoroughly covered using RSpec. This includes explicit testing for seat hold creation, the 5-minute expiry logic, double-booking prevention, and the cancellation fee calculations.