"Name: \PR:ZHMXCDTA0\FO:PROCESS_EVP_RGDIR\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH013_CTDA.
data wa_tabla type ZCCHRTT_SFPPROT.

if soc is not initial.
if pernr-bukrs <> soc.
  exit.
endif.
endif.
if pmotivo is not initial.
delete evp_rgdir where ocrsn <> pmotivo.
endif.

select single * from ZCCHRTT_SFPPROT
into wa_tabla
where bukrs = pernr-bukrs
and persa = pernr-werks.
  if sy-subrc = 0.
    if wa_tabla-EMFSL_SPF <> EMFSL.
      exit.
    endif.
   endif.


ENDENHANCEMENT.
