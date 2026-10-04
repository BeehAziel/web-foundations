# Library Books API

Base URL: `/api`

## Endpoints

### List books

- **Method:** `GET`
- **Path:** `/books`
- **Description:** Returns the collection of books.
- **Success status:** `200 OK`

### Get one book

- **Method:** `GET`
- **Path:** `/books/{id}`
- **Description:** Returns the book with the specified ID.
- **Success status:** `200 OK`

### Create a book

- **Method:** `POST`
- **Path:** `/books`
- **Description:** Creates a book and returns the created resource.
- **Example request body:**
  ```json
  {
    "title": "The Hobbit",
    "author": "J. R. R. Tolkien",
    "publishedYear": 1937
  }