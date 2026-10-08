-- R2 Esc5 — nivel de nomenclatura
-- Escenario: Nomenclaturas distintas: menor nivel pierde
-- Fuente: edf_views → bdm_tempo.v_xpm_* | Salida: bdm_datos.unificacion_direccion
-- Prerequisito: sp_unificacion_r2_esc4_diccionario_frecuencia_complemento
-- Generado: tools/gen_unificacion_sps_por_escenario.py

CREATE OR REPLACE PROCEDURE bdm_datos.sp_unificacion_r2_esc5_nomenclatura_menor_nivel_pierde()
NONATOMIC
LANGUAGE plpgsql
AS $$
BEGIN
  CREATE TABLE bdm_tempo.stg_regla2_e05
  DISTSTYLE KEY DISTKEY(id_buro_persona)
  AS
  SELECT DISTINCT a.*
  FROM (SELECT * FROM bdm_tempo.stg_regla2_e2 WHERE ind_unificacion = 'N') a
  JOIN (SELECT * FROM bdm_tempo.stg_regla2_e2 WHERE ind_unificacion = 'N') b
    ON a.id_buro_persona = b.id_buro_persona
   AND a.texto_ubicacion = b.texto_ubicacion
   AND a.cod_dw_tipo_ubicacion_dir = b.cod_dw_tipo_ubicacion_dir
   AND a.cod_dw_municipio = b.cod_dw_municipio
   AND a.cod_dw_persona_ubic <> b.cod_dw_persona_ubic
   AND a.complemento <> b.complemento;

  CREATE TABLE bdm_tempo.stg_regla2_e05_a
  DISTSTYLE KEY DISTKEY(id_buro_persona)
  AS
  SELECT DISTINCT
    a.*,
    nmc1.nomenclatura AS nomenclatura_pri,
    nmc1.nivel_complemento AS nivel_pri
  FROM bdm_tempo.stg_regla2_e05 a
  LEFT JOIN bdm_datos.nomenclatura nmc1
    ON a.complemento LIKE TRIM(nmc1.nomenclatura) || ' %';

  CREATE TABLE bdm_tempo.stg_regla2_e05_pares
  DISTSTYLE KEY DISTKEY(cod_dw_persona_ubic)
  AS
  SELECT DISTINCT
    b.cod_dw_persona_ubic,
    a.cod_dw_persona_ubic AS id_padre
  FROM bdm_tempo.stg_regla2_e05_a a
  JOIN bdm_tempo.stg_regla2_e05_a b
    ON a.id_buro_persona = b.id_buro_persona
   AND a.texto_ubicacion = b.texto_ubicacion
   AND a.cod_dw_tipo_ubicacion_dir = b.cod_dw_tipo_ubicacion_dir
   AND a.cod_dw_municipio = b.cod_dw_municipio
   AND a.cod_dw_persona_ubic <> b.cod_dw_persona_ubic
   AND a.complemento <> b.complemento
   AND COALESCE(a.nivel_pri,99) < COALESCE(b.nivel_pri,99)
  WHERE a.nomenclatura_pri IS NOT NULL
    AND b.nomenclatura_pri IS NOT NULL
    AND a.nomenclatura_pri <> b.nomenclatura_pri;

  INSERT INTO bdm_datos.unificacion_direccion
  SELECT DISTINCT
    cod_dw_persona_ubic,
    id_padre,
    2,
    CURRENT_DATE,
    1,
    1,
    LEFT(CURRENT_USER,30)
  FROM bdm_tempo.stg_regla2_e05_pares;

  UPDATE bdm_tempo.stg_regla2_e2
  SET id_padre = e.id_padre,
      ind_unificacion = 'S',
      n_id = 'E5'
  FROM bdm_tempo.stg_regla2_e05_pares e
  WHERE bdm_tempo.stg_regla2_e2.cod_dw_persona_ubic = e.cod_dw_persona_ubic
    AND bdm_tempo.stg_regla2_e2.id_padre IS NULL;


END;
$$;
