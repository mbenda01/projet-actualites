package iibs.actualites.exception;

import org.springframework.core.*;
import org.springframework.http.*;
import org.springframework.http.converter.*;
import org.springframework.http.server.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.*;

@RestControllerAdvice(basePackages = "iibs.actualites.controller")
public class ApiResponseBodyAdvice implements ResponseBodyAdvice<Object> {

    @Override
    public boolean supports(
            MethodParameter typeRetour,
            Class<? extends HttpMessageConverter<?>> typeConvertisseur
    ) {
        return true;
    }

    @Override
    public Object beforeBodyWrite(
            Object corps,
            MethodParameter typeRetour,
            MediaType typeContenu,
            Class<? extends HttpMessageConverter<?>> typeConvertisseur,
            ServerHttpRequest requete,
            ServerHttpResponse reponse
    ) {
        if (corps instanceof ApiResponse<?>) {
            return corps;
        }

        if (corps instanceof String) {
            return corps;
        }

        int statut = ((ServletServerHttpResponse) reponse)
                .getServletResponse().getStatus();

        return ApiResponse.succes(corps, "Operation reussie", HttpStatus.valueOf(statut));
    }
}