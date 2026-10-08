-- R2 Esc1 — complemento vacío absorbe con complemento
-- Escenario: R2 Esc2 — substring de complemento en mismo texto
-- Fuente: edf_views → bdm_tempo.v_xpm_* | Salida: bdm_datos.unificacion_direccion
-- Prerequisito: sp_unificacion_r2_preparar_insumo
-- Generado: tools/gen_unificacion_sps_por_escenario.py

CREATE OR REPLACE PROCEDURE bdm_datos.sp_unificacion_r2_esc1_complemento_vacio_esc2_substring_complemento()
NONATOMIC
LANGUAGE plpgsql
AS $$
BEGIN
  CREATE TABLE bdm_tempo.stg_regla2_esc1_pares
  DISTSTYLE KEY DISTKEY(cod_dw_persona_ubic)
  AS
  SELECT cod_dw_persona_ubic, id_padre
  FROM (
    SELECT
      b.cod_dw_persona_ubic,
      a.cod_dw_persona_ubic AS id_padre,
      ROW_NUMBER() OVER (PARTITION BY b.cod_dw_persona_ubic ORDER BY a.cod_dw_persona_ubic DESC) AS rn
    FROM bdm_tempo.stg_regla2_insumo a
    JOIN bdm_tempo.stg_regla2_insumo b
      ON a.id_buro_persona = b.id_buro_persona
     AND a.texto_ubicacion = b.texto_ubicacion
     AND a.cod_dw_tipo_ubicacion_dir = b.cod_dw_tipo_ubicacion_dir
     AND a.cod_dw_municipio = b.cod_dw_municipio
     AND a.cod_dw_persona_ubic <> b.cod_dw_persona_ubic
    WHERE a.complemento IS NOT NULL
      AND LENGTH(a.complemento) > 0
      AND (b.complemento IS NULL OR LENGTH(b.complemento) = 0)
  )
  WHERE rn = 1;

  CREATE TABLE bdm_tempo.stg_regla2_e1
  DISTSTYLE KEY DISTKEY(id_buro_persona)
  AS
  SELECT
    a.cod_dw_persona_ubic,
    b.id_padre,
    a.id_buro_persona,
    a.cod_dw_tipo_ubicacion_dir,
    a.cod_dw_ubic,
    a.texto_ubicacion,
    a.cod_dw_direccion_fisica,
    a.complemento,
    a.cod_dw_municipio,
    a.numero_entidades_reportan,
    a.fecha_relacion_persona_ubicaci,
    CASE WHEN b.cod_dw_persona_ubic IS NOT NULL THEN 'S' ELSE 'N' END AS ind_unificacion,
    CASE WHEN b.cod_dw_persona_ubic IS NOT NULL THEN 'H1' END AS n_id,
    ROW_NUMBER() OVER (
      PARTITION BY a.id_buro_persona, a.cod_dw_ubic,
        CASE WHEN b.cod_dw_persona_ubic IS NOT NULL THEN 'S' ELSE 'N' END,
        a.cod_dw_tipo_ubicacion_dir
      ORDER BY a.complemento
    ) AS row_u
  FROM bdm_tempo.stg_regla2_insumo a
  LEFT JOIN bdm_tempo.stg_regla2_esc1_pares b
    ON a.cod_dw_persona_ubic = b.cod_dw_persona_ubic;

  CREATE TABLE bdm_tempo.stg_regla2_esc2_pares
  DISTSTYLE KEY DISTKEY(cod_dw_persona_ubic)
  AS
  SELECT cod_dw_persona_ubic, id_padre
  FROM (
    SELECT
      b.cod_dw_persona_ubic,
      a.cod_dw_persona_ubic AS id_padre,
      ROW_NUMBER() OVER (PARTITION BY b.cod_dw_persona_ubic ORDER BY b.cod_dw_persona_ubic DESC) AS rn
    FROM bdm_tempo.stg_regla2_e1 a
    JOIN bdm_tempo.stg_regla2_e1 b
      ON a.id_buro_persona = b.id_buro_persona
     AND a.texto_ubicacion = b.texto_ubicacion
     AND a.cod_dw_tipo_ubicacion_dir = b.cod_dw_tipo_ubicacion_dir
     AND a.cod_dw_municipio = b.cod_dw_municipio
     AND a.cod_dw_persona_ubic <> b.cod_dw_persona_ubic
     AND a.complemento <> b.complemento
    WHERE a.complemento LIKE '%' || b.complemento || '%'
      AND a.ind_unificacion = 'N'
      AND b.ind_unificacion = 'N'
      AND LENGTH(b.complemento) > 0
  )
  WHERE rn = 1;

  CREATE TABLE bdm_tempo.stg_regla2_e2
  DISTSTYLE KEY DISTKEY(id_buro_persona)
  AS
  SELECT
    a.cod_dw_persona_ubic,
    CASE WHEN a.id_padre IS NOT NULL THEN a.id_padre ELSE b.id_padre END AS id_padre,
    a.id_buro_persona,
    a.cod_dw_tipo_ubicacion_dir,
    a.cod_dw_ubic,
    a.texto_ubicacion,
    a.cod_dw_direccion_fisica,
    a.complemento,
    a.cod_dw_municipio,
    a.numero_entidades_reportan,
    a.fecha_relacion_persona_ubicaci,
    CASE WHEN a.ind_unificacion = 'S' THEN 'S'
         WHEN b.cod_dw_persona_ubic IS NOT NULL THEN 'S'
         ELSE 'N' END AS ind_unificacion,
    CASE WHEN a.n_id IS NOT NULL THEN a.n_id
         WHEN b.cod_dw_persona_ubic IS NOT NULL THEN 'K2' END AS n_id,
    ROW_NUMBER() OVER (
      PARTITION BY a.id_buro_persona, a.cod_dw_ubic,
        CASE WHEN a.ind_unificacion = 'S' THEN 'S'
             WHEN b.cod_dw_persona_ubic IS NOT NULL THEN 'S'
             ELSE 'N' END,
        a.cod_dw_tipo_ubicacion_dir
      ORDER BY a.complemento
    ) AS row_u
  FROM bdm_tempo.stg_regla2_e1 a
  LEFT JOIN bdm_tempo.stg_regla2_esc2_pares b
    ON a.cod_dw_persona_ubic = b.cod_dw_persona_ubic;

  INSERT INTO bdm_datos.unificacion_direccion
  SELECT DISTINCT
    cod_dw_persona_ubic,
    id_padre,
    2,
    CURRENT_DATE,
    1,
    1,
    LEFT(CURRENT_USER, 30)
  FROM bdm_tempo.stg_regla2_e2
  WHERE ind_unificacion = 'S'
    AND id_padre IS NOT NULL;


END;
$$;
