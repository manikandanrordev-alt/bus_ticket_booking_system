document.addEventListener("turbo:load", () => {
  const page = document.querySelector(".seat-selection-page");

  if (!page) return;

  const ticketPrice = Number(page.dataset.ticketPrice || 0);
  const checkboxes = page.querySelectorAll(
    'input[name="trip_seat_ids[]"]'
  );
  const selectedSeatCount = page.querySelector("#selected-seat-count");
  const selectedTotal = page.querySelector("#selected-total");
  const holdSeatsButton = page.querySelector("#hold-seats-button");

  if (
    !selectedSeatCount ||
    !selectedTotal ||
    !holdSeatsButton
  ) {
    return;
  }

  function updateSelection() {
    const selectedSeats = page.querySelectorAll(
      'input[name="trip_seat_ids[]"]:checked'
    );

    const count = selectedSeats.length;
    const total = count * ticketPrice;

    selectedSeatCount.textContent = count;
    selectedTotal.textContent = `₹${total}`;

    holdSeatsButton.disabled = count === 0;

    checkboxes.forEach((checkbox) => {
      const seat = checkbox.closest(".seat");

      if (seat) {
        seat.classList.toggle("selected", checkbox.checked);
      }
    });
  }

  checkboxes.forEach((checkbox) => {
    checkbox.addEventListener("change", updateSelection);
  });

  updateSelection();
});