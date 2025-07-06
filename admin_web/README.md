# Admin Web

This is the admin web portal for the Second Innings project, built with Vue.js 3, Vite, and CSS. It provides administrative and support functionalities for managing the platform.

## Features

Based on the application's screens, here are the core features available to different user roles:

### General

- **Welcome Screen**: The landing page for users.
- **Login**: Authentication using Google Sign-In.
- **Registration**: Allows users to register as an Interest Group Admin.

### Officials (Super Admins)

- **User Management**:
  - View lists of all Support Users, Interest Group Admins (IGAs), and Caregivers.
  - Create new Support User accounts.
  - Edit credentials for Support Users.
  - Block or unblock users.
- **Review & Approval**:
  - Review and approve/reject applications from potential Caregivers.
  - Review and approve/reject applications from potential Interest Group Admins.

### Support Users

- **Ticket Management**:
  - View all support tickets submitted by users.
  - Reply to and resolve support tickets.
  - View details of individual tickets.

### Interest Group Admins (IGAs)

- **Group Management**:
  - Create and edit interest groups.
  - View and manage their own groups.
  - Check the registration status of their groups.
- **Member Management**:
  - View senior citizens who have expressed interest in their groups.
  - View groups that were rejected by the admin.

## Recommended IDE Setup

[VSCode](https://code.visualstudio.com/) + [Volar](https://marketplace.visualstudio.com/items?itemName=Vue.volar) (and disable Vetur).

## Customize configuration

See [Vite Configuration Reference](https://vite.dev/config/).

## Project Setup

```sh
npm install
```

### Compile and Hot-Reload for Development

```sh
npm run dev
```

### Compile and Minify for Production

```sh
npm run build
```

### Lint with [ESLint](https://eslint.org/)

```sh
npm run lint
```
