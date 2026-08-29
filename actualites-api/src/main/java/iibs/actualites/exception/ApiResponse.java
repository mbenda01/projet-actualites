package iibs.actualites.exception;

import org.springframework.http.*;

import java.time.*;

public record ApiResponse<T>(
        LocalDateTime timestamp,
        int statut,
        boolean succes,
        String message,
        T data
) {

    public static <T> ApiResponse<T> succes(T data, String message) {
        return new ApiResponse<>(LocalDateTime.now(), HttpStatus.OK.value(), true, message, data);
    }

    public static <T> ApiResponse<T> succes(T data, String message, HttpStatus statut) {
        return new ApiResponse<>(LocalDateTime.now(), statut.value(), true, message, data);
    }

    public static <T> ApiResponse<T> erreur(HttpStatus statut, String message) {
        return new ApiResponse<>(LocalDateTime.now(), statut.value(), false, message, null);
    }

    public static <T> ApiResponse<T> erreur(HttpStatus statut, String message, T data) {
        return new ApiResponse<>(LocalDateTime.now(), statut.value(), false, message, data);
    }
}