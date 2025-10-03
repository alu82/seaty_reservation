defmodule SeatyReservationWeb.FaqComponents do
  @moduledoc """
  Provides FAQ components for the reservation system.
  """
  use Phoenix.Component

  import SeatyReservationWeb.CoreComponents
  import SeatyReservationWeb.Gettext

  @doc """
  Renders the reservation FAQ section with all common questions and answers.
  """
  def reservation_faq(assigns) do
    ~H"""
    <.faq>
      <:item question={gettext("Wie und wann bezahle ich meine Reservierung?")}>
        <%= gettext("Die Bezahlung erfolgt bequem an der Abendkasse bei der Kartenabholung. Sie können sowohl bar als auch mit Karte bezahlen.") %>
      </:item>
      <:item question={gettext("Erhalte ich eine Bestätigung?")}>
        <%= gettext("Ja, Sie erhalten eine Bestätigung mit Reservierungsnummer an Ihre E-Mail-Adresse. Sollten Sie diese nicht erhalten haben, wenden Sie sich bitte an %{contact}. Ihre Reservierungsdetails können Sie jederzeit über den Bestätigungslink einsehen.",
          contact: System.get_env("SY_SMTP_USER")) %>
      </:item>
      <:item question={gettext("Wann ist Einlass?")}>
        <%= gettext("Der Einlass beginnt 90 Minuten vor Vorstellungsbeginn.") %>
      </:item>
      <:item question={gettext("Wann muss ich die Karten abholen?")}>
        <%= gettext("Bitte holen Sie Ihre reservierten Karten spätestens 30 Minuten vor Vorstellungsbeginn mit Ihrer Reservierungsnummer ab. Andernfalls verfällt die Reservierung und die Karten werden an der Abendkasse vergeben.") %>
      </:item>
      <:item question={gettext("Was passiert wenn jemand nicht kommen kann?")}>
        <%= gettext("Bitte teilen Sie Ausfälle so früh wie möglich mit - nicht erst an der Abendkasse. So können wir die Karten rechtzeitig für den Verkauf freigeben.") %>
      </:item>
      <:item question={gettext("Kann ich später noch zusätzliche Karten bestellen?")}>
        <%= gettext("Ja, zusätzliche Karten können Sie gerne separat buchen. Bitte geben Sie dabei Ihre bestehende Reservierungsnummer an. Wir bemühen uns, die Plätze angrenzend zu vergeben, können dies jedoch nicht garantieren.") %>
      </:item>
      <:item question={gettext("Kann ich meine Reservierung stornieren?")}>
        <%= gettext("Ja, eine Stornierung ist möglich. Bitte antworten Sie dazu auf Ihre Bestätigungs-E-Mail.") %>
      </:item>
      <:item question={gettext("Was wenn ich mehr Karten benötige als noch verfügbar sind?")}>
        <%= gettext("Bitte kontaktieren Sie uns per E-Mail. Wir setzen Sie gerne auf unsere Warteliste und reservieren die gewünschten Karten für Sie, sobald welche verfügbar werden.") %>
      </:item>
    </.faq>
    """
  end
end
