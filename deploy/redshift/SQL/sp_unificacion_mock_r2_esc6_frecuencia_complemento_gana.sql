-- R2 Esc6 — frecuencia de complemento
-- MODO MOCK — lee v_mock_*/bdm_stage; NO usa edf_views ni v_xpm_*
-- Escenario: Mayor frecuencia en diccionario gana
-- Fuente: bdm_stage → bdm_tempo.v_mock_* | Salida: bdm_datos.unificacion_direccion_mock | MODO MOCK
-- Prerequisito: sp_unificacion_mock_r2_esc5_nomenclatura_menor_nivel_pierde
-- Generado: tools/gen_unificacion_mock_sps.py (espejo mock)

CREATE OR REPLACE PROCEDURE bdm_datos.sp_unificacion_mock_r2_esc6_frecuencia_complemento_gana()
NONATOMIC
LANGUAGE plpgsql
AS $$
BEGIN
  CREATE TABLE bdm_tempo.stg_mock_regla2_e06_freq
  DISTSTYLE KEY DISTKEY(cod_dw_persona_ubic)
  AS
  SELECT
    a.cod_dw_persona_ubic,
    COALESCE(SUM(dc.frecuencia), 0) AS freq
  FROM (SELECT * FROM bdm_tempo.stg_mock_regla2_e2 WHERE ind_unificacion = 'N') a
  LEFT JOIN bdm_stage.diccionario_complementos dc
    ON a.cod_dw_ubic = dc.cod_dw_ubic
   AND a.complemento LIKE '%' || dc.nomenclatura || '%'
   AND a.id_buro_persona = dc.id_buro_persona
  GROUP BY 1;

  CREATE TABLE bdm_tempo.stg_mock_regla2_e06_pares
  DISTSTYLE KEY DISTKEY(cod_dw_persona_ubic)
  AS
  SELECT DISTINCT
    b.cod_dw_persona_ubic,
    a.cod_dw_persona_ubic AS id_padre
  FROM (SELECT * FROM bdm_tempo.stg_mock_regla2_e2 WHERE ind_unificacion = 'N') a
  JOIN (SELECT * FROM bdm_tempo.stg_mock_regla2_e2 WHERE ind_unificacion = 'N') b
    ON a.id_buro_persona = b.id_buro_persona
   AND a.texto_ubicacion = b.texto_ubicacion
   AND a.cod_dw_tipo_ubicacion_dir = b.cod_dw_tipo_ubicacion_dir
   AND a.cod_dw_municipio = b.cod_dw_municipio
   AND a.cod_dw_persona_ubic <> b.cod_dw_persona_ubic
   AND a.complemento <> b.complemento
  JOIN bdm_tempo.stg_mock_regla2_e06_freq fa
    ON a.cod_dw_persona_ubic = fa.cod_dw_persona_ubic
  JOIN bdm_tempo.stg_mock_regla2_e06_freq fb
    ON b.cod_dw_persona_ubic = fb.cod_dw_persona_ubic
  WHERE fa.freq > fb.freq;

  INSERT INTO bdm_datos.unificacion_direccion_mock
  SELECT DISTINCT
    cod_dw_persona_ubic,
    id_padre,
    2,
    CURRENT_DATE,
    1,
    1,
    LEFT(CURRENT_USER,30)
  FROM bdm_tempo.stg_mock_regla2_e06_pares;


END;
$$;
