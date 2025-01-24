CREATE DATABASE calidad_aire;
Use calidad_aire;
CREATE TABLE datos_calidad_aire (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    AQI INT,
    PM10 FLOAT,
    PM2_5 FLOAT,
    NO2 FLOAT,
    SO2 FLOAT,
    O3 FLOAT,
    Temperatura FLOAT,
    Humedad FLOAT,
    Vel_Viento FLOAT,
    Casos_Respiracion INT,
    Casos_Cardiovasculares INT,
    Admision_Hospital INT,
    P_IS FLOAT,
    C_IS FLOAT
);

show tables;

### DESARROLLO
#A. 5 preguntas sobre la base de datos que se pueda responder con SQL
## 1.	¿Cuál es el valor promedio del AQI en la base de datos?
SELECT AVG(AQI) AS promedio_AQI FROM datos_calidad_aire;
## 2.	¿Cuántos registros tienen más de 20 casos de problemas respiratorios?
SELECT COUNT(*) AS total_registros FROM datos_calidad_aire WHERE Casos_Respiracion > 20;
## 3.	¿Cuál es la temperatura máxima registrada en la base de datos?
SELECT MAX(Temperatura) AS temp_maxima FROM datos_calidad_aire;
## 4.	¿Cuántos registros hay en total en la base de datos?
SELECT COUNT(*) AS total_registros FROM datos_calidad_aire;
## 5.	¿Cuál es el valor mínimo de PM2.5 en la base de datos?
SELECT MIN(PM2_5) AS minimo_PM2_5 FROM datos_calidad_aire;



# B. 5 preguntas con reconocimiento de patrones, funciones de agrupamiento, agrupamiento y subconsultas.
## 1.	¿Cuál es el valor promedio de AQI por cada nivel de admisión hospitalaria?

SELECT Admision_Hospital, AVG(AQI) AS promedio_AQI 
FROM datos_calidad_aire 
GROUP BY Admision_Hospital;

## 2.	¿Cuántos registros tienen una temperatura mayor al promedio de todas las temperaturas?
SELECT COUNT(*) AS total_registros 
FROM datos_calidad_aire 
WHERE Temperatura > (SELECT AVG(Temperatura) FROM datos_calidad_aire);

## 3.	¿Cuál es la relación entre el promedio de PM10 y PM2?5 por nivel de casos de problemas cardiovasculares?

SELECT Casos_Cardiovasculares, AVG(PM10) AS promedio_PM10, AVG(PM2_5) AS promedio_PM2_5 
FROM datos_calidad_aire 
GROUP BY Casos_Cardiovasculares;

## 4.	¿Cuál es la velocidad del viento promedio para los días con más de 5 admisiones hospitalarias?
SELECT AVG(Vel_Viento) AS velocidad_promedio 
FROM datos_calidad_aire 
WHERE Admision_Hospital > 5;
## 5.	¿Cuántos casos de problemas respiratorios y cardiovasculares hay por cada nivel de calidad del aire (AQI)?
SELECT AQI, SUM(Casos_Respiracion) AS total_respiratorios, SUM(Casos_Cardiovasculares) AS total_cardiovasculares 
FROM datos_calidad_aire 
GROUP BY AQI;

## C. 5 preguntas complejas de uso de llaves primarias. Tipo de relaciones, relación de tablas mediante joins y creación de vistas.

CREATE TABLE IndiceCalidadAire (
    ID INT PRIMARY KEY,
    Pais VARCHAR(100),
    Ciudad VARCHAR(100),
    AQI FLOAT,
    Categoria_AQI VARCHAR(50)
);

## 1.	Crear una vista que combine datos de calidad del aire con información de índice de calidad del aire
CREATE VIEW VistaCalidadCompleta AS
SELECT 
    ICA.ID,
    ICA.Pais,
    ICA.Ciudad,
    ICA.AQI AS AQI_Indice,
    ICA.Categoria_AQI,
    DCA.AQI AS AQI_Detalle,
    DCA.PM10,
    DCA.PM2_5,
    DCA.NO2,
    DCA.SO2,
    DCA.O3,
    DCA.Temperatura,
    DCA.Humedad,
    DCA.Vel_Viento,
    DCA.Casos_Respiracion,
    DCA.Casos_Cardiovasculares,
    DCA.Admision_Hospital
FROM 
    IndiceCalidadAire ICA
JOIN 
    datos_calidad_aire DCA ON ICA.ID = DCA.ID;

 SELECT * FROM VistaCalidadCompleta;

 
## 2.	Obtener el promedio de los contaminantes por país
SELECT 
    Pais,
    AVG(PM10) AS Promedio_PM10,
    AVG(PM2_5) AS Promedio_PM2_5,
    AVG(NO2) AS Promedio_NO2,
    AVG(SO2) AS Promedio_SO2,
    AVG(O3) AS Promedio_O3
FROM 
    VistaCalidadCompleta
GROUP BY 
    Pais;
## 3.	Contar el número de ciudades en cada categoría de AQI
SELECT 
    Categoria_AQI,
    COUNT(DISTINCT Ciudad) AS Numero_Ciudades
FROM 
    VistaCalidadCompleta
GROUP BY 
    Categoria_AQI;
## 4.	Crear una vista para analizar la relación entre calidad del aire y casos de salud
CREATE VIEW VistaSaludCalidad AS
SELECT 
    Pais,
    Ciudad,
    AQI_Indice,
    Categoria_AQI,
    Casos_Respiracion,
    Casos_Cardiovasculares,
    Admision_Hospital
FROM 
    VistaCalidadCompleta;

## 5. ¿Cuál es la ciudad con el peor índice de calidad del aire (AQI_Indice) y el mayor número de admisiones hospitalarias?
SELECT 
    Ciudad, 
    MAX(AQI_Indice) AS Peor_AQI, 
    MAX(Admision_Hospital) AS Max_Admisiones
FROM 
    VistaSaludCalidad
GROUP BY 
    Ciudad
ORDER BY 
    Peor_AQI DESC, Max_Admisiones DESC
LIMIT 1;


