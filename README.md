# 📚 LSP-Library

LSP-Library is a macOS library management application built with **SwiftUI** and **Supabase**.  
It allows an admin to manage book collections and track borrowing activities in real time.

This app was built as part of an LSP (Lembaga Sertifikasi Profesi) project to demonstrate database-driven application development, UI design, and backend integration.

---

## App Overview

This app focuses on **simple but reliable borrowing management**:

- View all book collections
- Track who borrows which book
- See due dates, return dates, and late status
- Ensure books cannot be borrowed twice at the same time

---

## Main Features

### Admin Login
- Admin logs in using username & password
- Authentication is handled via a **Supabase RPC function**
- Session is stored locally to identify the active admin

### Book Collections
- Display all books
- Each book has:
  - Title
  - Year
  - Cover image
  - Availability status

Only books marked as `available = true` can be borrowed.

### Borrowings Management
Admins can see all borrowing records including:

- Book title & cover
- Borrower name
- Borrow date
- Due date
- Return date (if returned)
- Status: `borrowed`, `returned`, or `late`

The **late status** is calculated automatically based on the due date and current date.


### Create New Borrowing
- Admin enters borrower name
- Admin selects a book
- Only **available books** appear in the list
- Borrow date is set automatically
- Due date is calculated automatically by the database
- The selected book is marked as unavailable


### Mark as Returned
When a book is returned:
- The borrowing record is updated:
  - `status = returned`
  - `return_date = today`
- The book is marked as available again
- The list refreshes automatically from the database

---

## Database Design

The system uses three main tables:

### ADMINS
Stores admin login data

### COLLECTIONS
Stores all books

### BORROWINGS
Stores all borrowing transactions

---

## Architecture

The app follows **MVVM (Model–View–ViewModel)**

All data displayed in the UI comes directly from Supabase queries or database views.

---

## 📄 Documentation

Full documentation is available on Notion:
https://keziaelice.notion.site/LSP-Library-Documentation-2e49097b3f9d80ce9fe4fb2808d4312a?source=copy_link
