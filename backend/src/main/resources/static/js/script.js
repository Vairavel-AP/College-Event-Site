// Highlight the active nav link based on current page
document.addEventListener("DOMContentLoaded", () => {
  const page = window.location.pathname.split("/").pop() || "index.html";
  document.querySelectorAll(".navbar nav a").forEach(link => {
    if (link.getAttribute("href") === page) {
      link.classList.add("active");
    }
  });

  // Symposium countdown (Home page)
  const countdownEl = document.getElementById("countdown");
  if (countdownEl) {
    const eventDate = new Date("2026-09-15T09:00:00");
    const tick = () => {
      const diff = eventDate - new Date();
      if (diff <= 0) {
        countdownEl.textContent = "The symposium is happening now!";
        return;
      }
      const d = Math.floor(diff / (1000 * 60 * 60 * 24));
      const h = Math.floor((diff / (1000 * 60 * 60)) % 24);
      const m = Math.floor((diff / (1000 * 60)) % 60);
      countdownEl.textContent = `${d}d ${h}h ${m}m to go`;
    };
    tick();
    setInterval(tick, 60000);
  }

  // ---- Announcements page: fetch from GET /api/announcements ----
  const announcementsList = document.getElementById("announcementsList");
  if (announcementsList) {
    fetch("/api/announcements")
      .then(r => r.json())
      .then(items => {
        if (!items.length) {
          announcementsList.innerHTML = "<p>No announcements yet.</p>";
          return;
        }
        announcementsList.innerHTML = items.map(a => `
          <div class="announcement">
            <div class="date">Posted: ${a.date}</div>
            <h3>${a.title}</h3>
            <p>${a.message}</p>
          </div>
        `).join("");
      })
      .catch(() => {
        announcementsList.innerHTML = "<p>Could not load announcements right now. Please try again later.</p>";
      });
  }

  // ---- Registration page: POST to /api/registrations ----
  const regForm = document.getElementById("regForm");
  if (regForm) {
    regForm.addEventListener("submit", (e) => {
      e.preventDefault();

      const payload = {
        fullName: document.getElementById("fullName").value,
        college: document.getElementById("college").value,
        email: document.getElementById("email").value,
        eventTrack: document.getElementById("eventTrack").value,
        notes: document.getElementById("notes").value
      };

      const successBox = document.getElementById("regSuccess");
      successBox.style.display = "none";
      successBox.style.background = "#e7f9ee";
      successBox.style.color = "#1a7f4e";

      fetch("/api/registrations", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
      })
        .then(res => {
          if (!res.ok) throw new Error("Registration failed");
          return res.json();
        })
        .then(() => {
          successBox.textContent = "✅ Registration submitted! A confirmation email will be sent shortly.";
          successBox.style.display = "block";
          regForm.reset();
        })
        .catch(() => {
          successBox.textContent = "⚠️ Something went wrong submitting your registration. Please try again.";
          successBox.style.background = "#fdecea";
          successBox.style.color = "#b3261e";
          successBox.style.display = "block";
        });
    });
  }

});
