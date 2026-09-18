document.addEventListener("DOMContentLoaded", () => {
  const page = document.querySelector(".seat-selection-page");
  const seats = document.querySelectorAll(".seat.available");
  const selectedSeatCount = document.querySelector("#selected-seat-count");
  const selectedTotal = document.querySelector("#selected-total");
  const holdSeatsButton = document.querySelector("#hold-seats-button");

  if (!page || !selectedSeatCount || !selectedTotal || !holdSeatsButton) return;

  const ticketPrice = Number(page.dataset.ticketPrice || 0);

  function updateSelection() {
    const selectedSeats = document.querySelectorAll(
      ".seat.available input:checked"
    );

    const count = selectedSeats.length;
    const total = count * ticketPrice;

    selectedSeatCount.textContent = count;
    selectedTotal.textContent = `₹${total}`;

    holdSeatsButton.disabled = count === 0;

    document.querySelectorAll(".seat.available").forEach((seat) => {
      const checkbox = seat.querySelector("input");
      seat.classList.toggle("selected", checkbox.checked);
    });
  }

  seats.forEach((seat) => {
    const checkbox = seat.querySelector("input");

    checkbox.addEventListener("change", updateSelection);
  });

  updateSelection();
});