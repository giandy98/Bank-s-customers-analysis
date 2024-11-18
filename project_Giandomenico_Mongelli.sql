-- Tabella temporanea con le informazioni di base del cliente e il numero totale di conti
CREATE TEMPORARY TABLE temp_clienti_conti AS
SELECT 
    cl.id_cliente,
    MAX(CONCAT(cl.nome, ' ', cl.cognome)) AS nome_cognome,  
    TIMESTAMPDIFF(YEAR, MAX(cl.data_nascita), CURDATE()) AS età,  
    COUNT(co.id_conto) AS numero_conti
FROM 
    cliente AS cl
LEFT JOIN 
    conto AS co ON cl.id_cliente = co.id_cliente
GROUP BY 
    cl.id_cliente;

-- Tabella temporanea con il numero di conti distinti per tipologia
CREATE TEMPORARY TABLE temp_conti_tipologia AS
SELECT 
    cl.id_cliente,
    COUNT(CASE WHEN t_co.desc_tipo_conto = 'Conto Base' THEN 1 END) AS Conto_Base,
    COUNT(CASE WHEN t_co.desc_tipo_conto = 'Conto Business' THEN 1 END) AS Conto_Business,
    COUNT(CASE WHEN t_co.desc_tipo_conto = 'Conto Privati' THEN 1 END) AS Conto_Privati,
    COUNT(CASE WHEN t_co.desc_tipo_conto = 'Conto Famiglie' THEN 1 END) AS Conto_Famiglie
FROM 
    cliente AS cl
LEFT JOIN 
    conto AS co ON cl.id_cliente = co.id_cliente
LEFT JOIN 
    tipo_conto AS t_co ON co.id_tipo_conto = t_co.id_tipo_conto
GROUP BY 
    cl.id_cliente;

-- Tabella temporanea con il numero delle transazioni per tipologia di conto e gli importi transati
CREATE TEMPORARY TABLE temp_transazioni AS
SELECT 
    cl.id_cliente,

    -- Numero totale di transazioni in uscita e in entrata
    COUNT(CASE WHEN t_tr.segno = '-' THEN 1 END) AS numero_transazioni_in_uscita,
    COUNT(CASE WHEN t_tr.segno = '+' THEN 1 END) AS numero_transazioni_in_entrata,
    
    -- Importi totali delle transazioni in uscita e in entrata
    SUM(CASE WHEN t_tr.segno = '-' THEN tr.importo ELSE 0 END) AS importo_transazioni_in_uscita,
    SUM(CASE WHEN t_tr.segno = '+' THEN tr.importo ELSE 0 END) AS importo_transazioni_in_entrata,
    
    -- Numero di transazioni in uscita e in entrata per ogni tipologia di conto
    COUNT(CASE WHEN t_tr.segno = '-' AND t_co.desc_tipo_conto = 'Conto Base' THEN 1 END) AS numero_transazioni_uscita_Conto_Base,
    COUNT(CASE WHEN t_tr.segno = '+' AND t_co.desc_tipo_conto = 'Conto Base' THEN 1 END) AS numero_transazioni_entrata_Conto_Base,
    COUNT(CASE WHEN t_tr.segno = '-' AND t_co.desc_tipo_conto = 'Conto Business' THEN 1 END) AS numero_transazioni_uscita_Conto_Business,
    COUNT(CASE WHEN t_tr.segno = '+' AND t_co.desc_tipo_conto = 'Conto Business' THEN 1 END) AS numero_transazioni_entrata_Conto_Business,
    COUNT(CASE WHEN t_tr.segno = '-' AND t_co.desc_tipo_conto = 'Conto Privati' THEN 1 END) AS numero_transazioni_uscita_Conto_Privati,
    COUNT(CASE WHEN t_tr.segno = '+' AND t_co.desc_tipo_conto = 'Conto Privati' THEN 1 END) AS numero_transazioni_entrata_Conto_Privati,
    COUNT(CASE WHEN t_tr.segno = '-' AND t_co.desc_tipo_conto = 'Conto Famiglie' THEN 1 END) AS numero_transazioni_uscita_Conto_Famiglie,
    COUNT(CASE WHEN t_tr.segno = '+' AND t_co.desc_tipo_conto = 'Conto Famiglie' THEN 1 END) AS numero_transazioni_entrata_Conto_Famiglie,
    
    -- Importi delle transazioni in uscita per tipologia di conto
    SUM(CASE WHEN t_co.desc_tipo_conto = 'Conto Base' AND t_tr.segno = '-' THEN tr.importo ELSE 0 END) AS importo_transazioni_uscita_Conto_Base,
    SUM(CASE WHEN t_co.desc_tipo_conto = 'Conto Business' AND t_tr.segno = '-' THEN tr.importo ELSE 0 END) AS importo_transazioni_uscita_Conto_Business,
    SUM(CASE WHEN t_co.desc_tipo_conto = 'Conto Privati' AND t_tr.segno = '-' THEN tr.importo ELSE 0 END) AS importo_transazioni_uscita_Conto_Privati,
    SUM(CASE WHEN t_co.desc_tipo_conto = 'Conto Famiglie' AND t_tr.segno = '-' THEN tr.importo ELSE 0 END) AS importo_transazioni_uscita_Conto_Famiglie,
    
    -- Importi delle transazioni in entrata per tipologia di conto
    SUM(CASE WHEN t_co.desc_tipo_conto = 'Conto Base' AND t_tr.segno = '+' THEN tr.importo ELSE 0 END) AS importo_transazioni_entrata_Conto_Base,
    SUM(CASE WHEN t_co.desc_tipo_conto = 'Conto Business' AND t_tr.segno = '+' THEN tr.importo ELSE 0 END) AS importo_transazioni_entrata_Conto_Business,
    SUM(CASE WHEN t_co.desc_tipo_conto = 'Conto Privati' AND t_tr.segno = '+' THEN tr.importo ELSE 0 END) AS importo_transazioni_entrata_Conto_Privati,
    SUM(CASE WHEN t_co.desc_tipo_conto = 'Conto Famiglie' AND t_tr.segno = '+' THEN tr.importo ELSE 0 END) AS importo_transazioni_entrata_Conto_Famiglie
FROM 
    cliente AS cl
LEFT JOIN 
    conto AS co ON cl.id_cliente = co.id_cliente
LEFT JOIN 
    transazioni AS tr ON co.id_conto = tr.id_conto
LEFT JOIN 
    tipo_transazione AS t_tr ON tr.id_tipo_trans = t_tr.id_tipo_transazione
LEFT JOIN 
    tipo_conto AS t_co ON co.id_tipo_conto = t_co.id_tipo_conto
GROUP BY 
    cl.id_cliente;

-- Creazione della tabella denormalizzata con tutti gli indicatori
CREATE TABLE indicatori AS
SELECT 
    c.id_cliente,
    c.nome_cognome,
    c.età,
    
    -- Numero totale di transazioni in uscita e in entrata
    t.numero_transazioni_in_uscita,
    t.numero_transazioni_in_entrata,
    
    -- Importi totali delle transazioni in uscita e in entrata
    ROUND(t.importo_transazioni_in_uscita, 2) AS importo_transazioni_in_uscita,
    ROUND(t.importo_transazioni_in_entrata, 2) AS importo_transazioni_in_entrata,
    
    -- Numero totale di conti posseduti
    c.numero_conti,
    
    -- Numero di conti posseduti per tipologia di conto
    ct.Conto_Base,
    ct.Conto_Business,
    ct.Conto_Privati,
    ct.Conto_Famiglie,
    
    -- Numero transazioni in uscita per tipologia di conto
    t.numero_transazioni_uscita_Conto_Base,
    t.numero_transazioni_uscita_Conto_Business,
    t.numero_transazioni_uscita_Conto_Privati,
    t.numero_transazioni_uscita_Conto_Famiglie,
    
    -- Numero transazioni in entrata per tipologia di conto
    t.numero_transazioni_entrata_Conto_Base,
    t.numero_transazioni_entrata_Conto_Business,
    t.numero_transazioni_entrata_Conto_Privati,
    t.numero_transazioni_entrata_Conto_Famiglie,
    
    -- Importi transati in uscita per tipologia di conto
    ROUND(t.importo_transazioni_uscita_Conto_Base, 2) AS importo_transazioni_uscita_Conto_Base,
    ROUND(t.importo_transazioni_uscita_Conto_Business, 2) AS importo_transazioni_uscita_Conto_Business,
    ROUND(t.importo_transazioni_uscita_Conto_Privati, 2) AS importo_transazioni_uscita_Conto_Privati,
    ROUND(t.importo_transazioni_uscita_Conto_Famiglie, 2) AS importo_transazioni_uscita_Conto_Famiglie,
    
    -- Importi transati in entrata per tipologia di conto
    ROUND(t.importo_transazioni_entrata_Conto_Base, 2) AS importo_transazioni_entrata_Conto_Base,
    ROUND(t.importo_transazioni_entrata_Conto_Business, 2) AS importo_transazioni_entrata_Conto_Business,
    ROUND(t.importo_transazioni_entrata_Conto_Privati, 2) AS importo_transazioni_entrata_Conto_Privati,
    ROUND(t.importo_transazioni_entrata_Conto_Famiglie, 2) AS importo_transazioni_entrata_Conto_Famiglie
FROM 
    temp_clienti_conti AS c
LEFT JOIN 
    temp_conti_tipologia AS ct ON c.id_cliente = ct.id_cliente
LEFT JOIN 
    temp_transazioni AS t ON c.id_cliente = t.id_cliente;