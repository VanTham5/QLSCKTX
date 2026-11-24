package controller;

import java.nio.charset.StandardCharsets;

final class FormValidation {
    private FormValidation() {
    }

    static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    static int positiveId(String value) {
        try {
            return Math.max(0, Integer.parseInt(value));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    static boolean text(String value, int min, int max) {
        return value.length() >= min && value.length() <= max
                && value.indexOf('<') < 0 && value.indexOf('>') < 0;
    }

    static boolean username(String value) {
        return value.matches("[A-Za-z0-9_.-]{3,50}");
    }

    static boolean password(String value) {
        return value != null && !value.trim().isEmpty() && value.length() >= 6
                && value.getBytes(StandardCharsets.UTF_8).length <= 72;
    }

    static boolean contact(String phone, String email) {
        return (phone.isEmpty() || phone.matches("0[0-9]{9}"))
                && (email.isEmpty() || (email.length() <= 100
                && email.matches("[^\\s@<>]+@[^\\s@<>]+\\.[^\\s@<>]+")));
    }
}
