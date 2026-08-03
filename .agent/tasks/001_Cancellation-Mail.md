# 001: Cancellation Mail Template

## User story

As a guest that just cancelled the reservation, I want to get a cancellation mail, in order to be sure that the action was successful.

## Acceptance criteria

- [ ] New cancellation template created with minimal formatting
- [ ] Cancellation Mail is sent when Reservation was cancelled
- [ ] The subject is built like the confirmation subject, but instead of "Reservierung erfolgreich" it has the text "Reservierung storniert"
- [ ] The following information is in the mail
  - Name of the person
  - Date of the event
  - link to the cancelled reservation
- [ ] Mail is sent only after successful cancellation

## Technical notes

- the current implementation reuses the confirmation template, which is a temporary solution. This needs to be replaced with the new cancellation template.

## Status

Done
