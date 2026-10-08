-- R3 Esc1 — misma vía, puerta más cercana (±2)
-- Escenario: Unificación geo por proximidad de número de puerta
-- Fuente: edf_views → bdm_tempo.v_xpm_* | Salida: bdm_datos.unificacion_direccion
-- Prerequisito: Regla 2 ejecutada; lat/long en insumo
-- Generado: tools/gen_unificacion_sps_por_escenario.py

CREATE OR REPLACE PROCEDURE bdm_datos.sp_unificacion_r3_esc1_geo_misma_via_puerta_cercana()
NONATOMIC
LANGUAGE plpgsql
AS $$
BEGIN
-- Limpieza de staging de esta regla
DROP TABLE IF EXISTS bdm_tempo.stg_regla3_pares;

  -- ==========================================================
  -- REGLA 3
  -- Version validada en la corrida 20K.
  -- ==========================================================

  CREATE TABLE bdm_tempo.stg_regla3_insumo
  DISTSTYLE KEY DISTKEY(id_buro_persona)
  AS
  SELECT
    rpu.cod_dw_persona_ubic,
    rpu.id_buro_persona,
    ubi.texto_ubicacion,
    df.complemento,
    ubi.cod_dw_ciudad AS cod_dw_municipio,
    ubi.latitud,
    ubi.longitud,
    COALESCE(cnt.numero_entidades_reportan, 0) AS numero_entidades_reportan
  FROM bdm_tempo.v_xpm_relacion_persona_ubicacion rpu
  JOIN bdm_tempo.v_xpm_ubicacion_estandarizada ubi
    ON rpu.cod_dw_ubic = ubi.cod_dw_ubic
  LEFT JOIN bdm_tempo.v_xpm_direccion_fisica df
    ON rpu.cod_dw_direccion_fisica = df.cod_dw_direccion_fisica
  LEFT JOIN (
    SELECT cod_dw_persona_ubic, COUNT(DISTINCT id_buro_suscriptor) AS numero_entidades_reportan
    FROM bdm_tempo.v_xpm_reporte_relacion_persona_ubica
    GROUP BY 1
  ) cnt
    ON rpu.cod_dw_persona_ubic = cnt.cod_dw_persona_ubic
  WHERE rpu.ind_unificacion IS NULL;

  CREATE TABLE bdm_tempo.stg_regla3_pares
  DISTSTYLE KEY DISTKEY(cod_dw_persona_ubic)
  AS
  SELECT DISTINCT
    b.cod_dw_persona_ubic,
    a.cod_dw_persona_ubic AS id_padre
  FROM bdm_tempo.stg_regla3_insumo a
  JOIN bdm_tempo.stg_regla3_insumo b
    ON a.id_buro_persona = b.id_buro_persona
   AND a.cod_dw_municipio = b.cod_dw_municipio
   AND a.cod_dw_persona_ubic <> b.cod_dw_persona_ubic
   AND SPLIT_PART(a.texto_ubicacion,' ',1) = SPLIT_PART(b.texto_ubicacion,' ',1)
   AND SPLIT_PART(a.texto_ubicacion,' ',2) = SPLIT_PART(b.texto_ubicacion,' ',2)
   AND (
     ABS(CAST(SPLIT_PART(a.texto_ubicacion,' ',3) AS INTEGER) - CAST(SPLIT_PART(b.texto_ubicacion,' ',3) AS INTEGER)) BETWEEN 1 AND 2
     OR ABS(CAST(SPLIT_PART(a.texto_ubicacion,' ',4) AS INTEGER) - CAST(SPLIT_PART(b.texto_ubicacion,' ',4) AS INTEGER)) BETWEEN 1 AND 2
   )
   AND a.numero_entidades_reportan > b.numero_entidades_reportan
  WHERE a.latitud IS NOT NULL
    AND b.latitud IS NOT NULL;

  INSERT INTO bdm_datos.unificacion_direccion
  SELECT DISTINCT
    cod_dw_persona_ubic,
    id_padre,
    3,
    CURRENT_DATE,
    1,
    1,
    LEFT(CURRENT_USER,30)
  FROM bdm_tempo.stg_regla3_pares;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla3_insumo;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla3_pares;

END;
$$;
