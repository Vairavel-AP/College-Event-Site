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

  // Registration form (client-side demo only)
  const regForm = document.getElementById("regForm");
  if (regForm) {
    regForm.addEventListener("submit", (e) => {
      e.preventDefault();
      document.getElementById("regSuccess").style.display = "block";
      regForm.reset();
    });
  }

  // Show a small build/version tag pulled from build-info.json (created at Docker build time)
  const buildInfoEl = document.getElementById("buildInfo");
  if (buildInfoEl) {
    fetch("build-info.json")
      .then(r => r.json())
      .then(data => {
        buildInfoEl.textContent = `Build ${data.version} · deployed ${data.buildTime}`;
      })
      .catch(() => {
        buildInfoEl.textContent = "";
      });
  }
});
