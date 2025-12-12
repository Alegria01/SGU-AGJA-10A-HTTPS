package mx.edu.utez.server.config;

import mx.edu.utez.server.utils.APIResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<APIResponse> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        
        ex.getBindingResult().getFieldErrors().forEach(error -> 
            errors.put(error.getField(), error.getDefaultMessage())
        );

        APIResponse response = new APIResponse(
            "Errores de validación en los datos enviados",
            errors,
            true,
            HttpStatus.BAD_REQUEST
        );

        return ResponseEntity.badRequest().body(response);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<APIResponse> handleGeneralException(Exception ex) {
        System.err.println("Error no controlado: " + ex.getMessage());
        ex.printStackTrace();

        APIResponse response = new APIResponse(
            "Error interno del servidor",
            null,
            true,
            HttpStatus.INTERNAL_SERVER_ERROR
        );

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }
}