package mx.edu.utez.server.modules.user.dto;

import jakarta.validation.constraints.*;

public class UpdateUserDTO {

    @NotNull(message = "El ID es obligatorio para actualizar")
    @Min(value = 1, message = "El ID debe ser mayor a 0")
    private Long id;

    @NotBlank(message = "El nombre completo es obligatorio")
    @Size(min = 2, max = 100, message = "El nombre debe tener entre 2 y 100 caracteres")
    @Pattern(regexp = "^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$", message = "El nombre solo puede contener letras y espacios")
    private String name;

    @NotBlank(message = "El teléfono es obligatorio")
    @Size(min = 10, max = 10, message = "El teléfono debe tener exactamente 10 dígitos")
    @Pattern(regexp = "^[0-9]{10}$", message = "El teléfono debe tener exactamente 10 dígitos")
    private String phone;

    @NotBlank(message = "El email es obligatorio")
    @Email(message = "El formato del email no es válido")
    @Size(min = 5, max = 150, message = "El email debe tener entre 5 y 150 caracteres")
    @Pattern(regexp = "^[a-z0-9][a-z0-9_.]{3,}@[a-z]{2,}(\\.[a-z]{2,}){1,2}$", message = "El email debe tener un formato válido")
    private String email;

    // Constructors
    public UpdateUserDTO() {
    }

    public UpdateUserDTO(Long id, String name, String phone, String email) {
        this.id = id;
        this.name = name;
        this.phone = phone;
        this.email = email;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    @Override
    public String toString() {
        return "UpdateUserDTO{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", phone='" + phone + '\'' +
                ", email='" + email + '\'' +
                '}';
    }
}