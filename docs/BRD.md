# Business Requirements Document (BRD)

**Project:** Feel chat
**Version:** 1.0
**Date:** Febreary 13, 2026

## Project Overview

Feel chat is a mobile application designed to let users share their feelings while remaining anonymous. Its goal is to help users manage their emotions and express what they feel without the fear of being judged. Additionally, it serves as a safe and private space to meet new people from their city or country.

## User Stories

- As a student, I want to remain anonymous while I gain the confidence to meet someone.

- As an insecure person, I would like to be able to add a person as a friend if I enjoy talking with them.

- As a shy person, I would like the app to suggest people from my city or country.

- As a busy student, I would like to receive notifications when someone sends me a message.

- As a student, I want to be able to report someone if they are unkind.

## System Requirements

### Functional Requirements

#### User Account Management:

- The system must allow users to create an account by providing a username, password, age, and city/country.

- The system must allow users to update their information (e.g., password, city).

- The system must allow users to permanently delete their account.

#### Search and Contact:

- The system must allow users to search for other users by their username to start a conversation.

#### Private Messaging:

- The system must provide private and secure chats between two users.

- Chats must support text messages.

- Users must be able to block other users to stop receiving messages from them.

#### Push Notifications:

- The system must send a push notification to a user when they receive a new message.

- Users must be able to configure notification settings (on/off) from within the app.

#### Reporting System:

- Users must be able to report other users by selecting a reason (e.g., harassment, spam, offensive language).

- Reports must be sent to an administration panel for review.

#### Password Recovery:

- The system must allow users to request an email with a secure, time-limited link to reset their forgotten password.

#### User Discovery (Suggestions):

- The system must suggest other people from the user's same city or country to encourage new conversations.

- Suggestions may be based on the location provided by the user.

### Non-Functional Requirements

- Privacy: User anonymity must be a top priority. Real names or personal contact information must not be displayed.

- Usability: The interface must be intuitive, simple, and welcoming, especially for users who may be shy or insecure.

- Performance: The application must be fast and lightweight. Messages must be sent and received with minimal latency.

- Security: All communication between the app and the server must be encrypted. Passwords must be stored securely.

- Availability: The application must have high availability, minimizing downtime.

- Maintainability: The code must be well-structured to allow for the easy addition of new features (e.g., emotion stickers, feeling-based chat rooms) in the future.
