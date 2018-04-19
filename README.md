# DockerMakiPrediction

docker-prediction-maki
======================

Ejecuta MAKI PredictionIO en Docker

1. Clona este repositorio

2. Construye la imagen del dockerfile 
    
    ```Bash
    $ docker build -t bigdatamx/predictionmaki .
    ```
    
3. Ejecuta el contenedor

    ```Bash
    $ docker run -p 9000:9000 -p 8000:8000 -p 7070:7070 --name predictionmaki_instance -it bigdatamx/predictionmaki /bin/bash
    ```

4. Dentro del contenedor ejecuta el siguiente comando para levantar los servicios

    ```Bash
    $ pio-start-all
    ```
   
   Verifica que los servicios esten arriba

    ```Bash
    $ jps -l
    ```

5. Moverse al  engine-recomendacion-maki-master, en la consola tipear :

```$cd PredictionIO-0.12.0-incubating/Enignes/engine-recomendacion-maki-master/```


6. Crear app , en la consola tipear :

```$pio app new app_name``` 

Ejemplo :

```$pio app new ourrecommendation```



7. Ver nombre y key de la app, en la consola tipear :

```$pio app list```


8. Editar engige : 

```nano  engine.json```  y remplazar  el  "INVALID_APP"  por   "el_nombre_app"

Ejemplo :

remplazar el  "INVALID_APP"  por   "ourrecommendation"


9. Agregar datos al event server



10. Construir el engine, tipear :

```pio build --verbose```


11. Una vez teniendo datos en el event server, entrenar el engine tipear :

```pio train```


12. Deploy al engine, tipear :
```pio deploy```


13 . Checar el status del engine :
Verificar en el navegador :  localhost:8080  ó    ip_del_host:8080


14. RealiRelizar consultas:

* realizar consultas al event server:

get ejemplo :

http://localhost:7070/events.json?accessKey=$APP_KEY



* realizar peticiones y obtener recomendaciones es de la siguente manera al engine:

post ejemplo:

curl -H "Content-Type: application/json" \
-d '{ "user": "16727", "num": 4 }' http://localhost:8000/queries.json




 La consola esta disponible en el puertos 9000

### Referencias:

 * Nos basamos en este Dockerfile [docker-predictionio](https://github.com/steveny2k/docker-predictionio)
* Para mas información checar : http://predictionio.apache.org/templates/recommendation/quickstart/  y
http://predictionio.apache.org

=========================
