package mx.edu.utez.server.modules.user;

import mx.edu.utez.server.utils.APIResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;

    @Transactional(readOnly = true)
    public APIResponse findAll(){
        List<User> list = new ArrayList<>();
        list = userRepository.findAll();

        return new APIResponse("Operación Exitosa", list,false, HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public APIResponse findById(Long id ){

        try{
            User found = userRepository.findById(id).orElse(null);
            if(found == null){
                return new APIResponse("El usuario no existe", true, HttpStatus.NOT_FOUND);
            }
            return new APIResponse("Operación Exitosa", found,false, HttpStatus.OK);
        }catch(Exception ex){
            ex.printStackTrace();
            return new APIResponse("No se pudo consultar el usuario", true, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Transactional(rollbackFor = {SQLException.class, Exception.class})
    public APIResponse saveUser(User payload) {
        try{
            if(userRepository.findByEmail(payload.getEmail()).isPresent()){
                return new APIResponse("Usuario ya existente", true, HttpStatus.BAD_REQUEST);
            }

            userRepository.save(payload);
            return new APIResponse("Usuario guardado correctamente", false, HttpStatus.CREATED);
        }catch(Exception ex){
            ex.printStackTrace();
            return new APIResponse("Error al guardar", true, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Transactional(rollbackFor = {SQLException.class, Exception.class})
    public APIResponse updateUser(User payload){
        try {
            User found = userRepository.findById(payload.getId()).orElse(null);
            if(found == null) {
                return new APIResponse("El usuario no existe", true, HttpStatus.NOT_FOUND);
            }
            userRepository.save(payload);
            return new APIResponse("Usuario actualizado correctamente", false, HttpStatus.OK);
        }catch (NullPointerException nullex){
            nullex.printStackTrace();
            return new APIResponse("No se aceptan valors nulos", true, HttpStatus.BAD_REQUEST);
        }catch (Exception ex) {
            ex.printStackTrace();
            return new APIResponse("No se pudo actualizar el usuario", true, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Transactional(rollbackFor = {SQLException.class, Exception.class})
    public APIResponse deleteUser(User payload) {
        try {
            User found = userRepository.findById(payload.getId()).orElse(null);
            if(found == null) {
                return new APIResponse("El Usuario no existe", true, HttpStatus.NOT_FOUND);
            }
            userRepository.deleteById(found.getId());
            return new APIResponse("Usuario eliminado correctamente", false, HttpStatus.OK);
        }catch (Exception ex) {
            ex.printStackTrace();
            return new APIResponse("No se pudo eliminar el usuario", true, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

}
