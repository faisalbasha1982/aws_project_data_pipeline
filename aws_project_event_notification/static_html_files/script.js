const apiBase = 'https://88j433miia.execute-api.us-east-1.amazonaws.com/prod';

document.getElementById('subscribe-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const email = document.getElementById('email').value;

  const response = await fetch(`${apiBase}/subscribers`, {
    method: 'POST',
    body: JSON.stringify({ email }),
    headers: { 'Content-Type': 'application/json' }
  });

  alert('Subscription request sent. Please confirm via email.');
});

document.getElementById('event-form').addEventListener('submit', async (e) => {
  e.preventDefault();

  const title = document.getElementById('title').value;
  const location = document.getElementById('location').value;
  const date = document.getElementById('date').value;

  const response = await fetch(`${apiBase}/new-events`, {
    method: 'POST',
    body: JSON.stringify({ title, location, date }),
    headers: { 'Content-Type': 'application/json' }
  });

  alert('Event submitted.');
  loadEvents();
});


async function loadEvents() {
  const response = await fetch('https://event-announcement-site-bucket.s3.us-east-1.amazonaws.com/events.json');
  if (!response.ok) {
    throw new Error('Network response was not ok');
  }

  const text = await response.text();
  if (!text) {
    console.warn('Empty response, returning empty array');
    return [];
  }

  try {
    const events = JSON.parse(text);
    // Render events to the page
    const list = document.getElementById('event-list');
    list.innerHTML = '';
    events.forEach(e => {
      const item = document.createElement('li');
      item.textContent = `${e.title} @ ${e.location} on ${e.date}`;
      list.appendChild(item);
    }); 
  } catch (err) {
    console.error('Failed to parse JSON:', err);
  }
}


loadEvents();

