const loadButton = document.querySelector("#load-users");
const filterInput = document.querySelector("#filter-input");
const statusElement = document.querySelector("#status");
const usersList = document.querySelector("#users-list");

let users = [];

function renderUsers(list) {
  usersList.replaceChildren();

  if (list.length === 0) {
    statusElement.textContent = "No users match your filter.";
    return;
  }

  list.forEach((user) => {
    const item = document.createElement("li");
    const name = document.createElement("h2");
    const email = document.createElement("p");
    const city = document.createElement("p");
    const company = document.createElement("p");

    name.textContent = user.name;
    email.textContent = `Email: ${user.email}`;
    city.textContent = `City: ${user.address.city}`;
    company.textContent = `Company: ${user.company.name}`;

    item.append(name, email, city, company);
    usersList.append(item);
  });

  statusElement.textContent = `Loaded ${list.length} ${
    list.length === 1 ? "user" : "users"
  }.`;
}

async function loadUsers() {
  loadButton.disabled = true;
  statusElement.textContent = "Loading users...";
  usersList.replaceChildren();

  try {
    const response = await fetch("https://jsonplaceholder.typicode.com/users");

    if (!response.ok) {
      throw new Error(`Request failed with status ${response.status}`);
    }

    users = await response.json();
    renderUsers(users);
  } catch (error) {
    users = [];
    usersList.replaceChildren();
    statusElement.textContent = "Unable to load users. Please try again.";
    console.error("Error loading users:", error);
  } finally {
    loadButton.disabled = false;
  }
}

loadButton.addEventListener("click", loadUsers);

filterInput.addEventListener("input", () => {
  const query = filterInput.value.trim().toLowerCase();
  const filteredUsers = users.filter((user) =>
    user.name.toLowerCase().includes(query)
  );

  renderUsers(filteredUsers);
});