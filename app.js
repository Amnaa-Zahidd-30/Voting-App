let user = null;

// REGISTER
async function register() {
  await fetch("/api/register", {
    method:"POST",
    headers:{"Content-Type":"application/json"},
    body: JSON.stringify({
      username: username.value,
      password: password.value
    })
  });
  alert("Registered");
}

// LOGIN
async function login() {
  const res = await fetch("/api/login", {
    method:"POST",
    headers:{"Content-Type":"application/json"},
    body: JSON.stringify({
      username: username.value,
      password: password.value
    })
  });

  const data = await res.json();

  if (data.error) {
    alert(data.error);
  } else {
    user = data;
    auth.style.display = "none";
    voteBox.style.display = "block";
    loadCandidates();
  }
}

// LOAD CANDIDATES
async function loadCandidates() {
  const res = await fetch("/api/candidates");
  const data = await res.json();

  candidates.innerHTML = "";

  data.forEach(c => {
    candidates.innerHTML += `
      <li>
        ${c.Name}
        <button onclick="vote(${c.candidate_ID})">Vote</button>
      </li>
    `;
  });
}

// VOTE
async function vote(id) {
  const res = await fetch("/api/vote", {
    method:"POST",
    headers:{"Content-Type":"application/json"},
    body: JSON.stringify({
      user_id: user.user_id,
      candidate_ID: id
    })
  });

  const data = await res.json();
  alert(data.error || "Vote Done");
  loadResults();
}

// RESULTS
async function loadResults() {
  const res = await fetch("/api/results");
  const data = await res.json();

  results.innerHTML = "";

  data.forEach(c => {
    results.innerHTML += `<li>${c.Name} - ${c.votes}</li>`;
  });
}

loadResults();