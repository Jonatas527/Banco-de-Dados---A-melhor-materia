1. Listagem de Autores:

sql
DELIMITER //

CREATE PROCEDURE sp_ListarAutores()
BEGIN
    SELECT * FROM Autor;
END //

DELIMITER ;


CALL sp_ListarAutores();

2. Livros por Categoria:

sql
DELIMITER //

CREATE PROCEDURE sp_LivrosPorCategoria(IN categoriaNome VARCHAR(100))
BEGIN
    SELECT Livro.Titulo
    FROM Livro
    INNER JOIN Categoria ON Livro.Categoria_ID = Categoria.Categoria_ID
    WHERE Categoria.Nome = categoriaNome;
END //

DELIMITER ;


CALL sp_LivrosPorCategoria('Romance');

3. *Contagem de Livros por Categoria*:

sql
DELIMITER //

CREATE PROCEDURE sp_ContarLivrosPorCategoria(IN categoriaNome VARCHAR(100), OUT totalLivros INT)
BEGIN
    SELECT COUNT(*) INTO totalLivros
    FROM Livro
    INNER JOIN Categoria ON Livro.Categoria_ID = Categoria.Categoria_ID
    WHERE Categoria.Nome = categoriaNome;
END //

DELIMITER ;

CALL sp_ContarLivrosPorCategoria('Ciência', @total);
SELECT @total AS 'Total de Livros';

4. *Verificação de Livros por Categoria*:

sql
DELIMITER //

CREATE PROCEDURE sp_VerificarLivrosCategoria(IN categoriaNome VARCHAR(100), OUT possuiLivros BOOLEAN)
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM Livro
    INNER JOIN Categoria ON Livro.Categoria_ID = Categoria.Categoria_ID
    WHERE Categoria.Nome = categoriaNome;

    IF total > 0 THEN
        SET possuiLivros = TRUE;
    ELSE
        SET possuiLivros = FALSE;
    END IF;
END //

DELIMITER ;

CALL sp_VerificarLivrosCategoria('Autoajuda', @temLivros);
SELECT IF(@temLivros, 'Possui Livros', 'Não Possui Livros') AS 'Categoria';

5. *Listagem de Livros por Ano*:

sql
DELIMITER //

CREATE PROCEDURE sp_LivrosAteAno(IN anoLimite INT)
BEGIN
    SELECT Titulo
    FROM Livro
    WHERE Ano_Publicacao <= anoLimite;
END //

DELIMITER ;

CALL sp_LivrosAteAno(2010);

6. *Extração de Títulos por Categoria (Usando Cursor)*:

sql
DELIMITER //

CREATE PROCEDURE sp_TitulosPorCategoria(IN categoriaNome VARCHAR(100))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE livroTitulo VARCHAR(255);
    DECLARE cur CURSOR FOR
        SELECT Livro.Titulo
        FROM Livro
        INNER JOIN Categoria ON Livro.Categoria_ID = Categoria.Categoria_ID
        WHERE Categoria.Nome = categoriaNome;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO livroTitulo;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT livroTitulo;
    END LOOP;
    CLOSE cur;
END //

DELIMITER ;

-- Teste da stored procedure
CALL sp_TitulosPorCategoria('Ficção Científica');

7. *Adição de Livro com Tratamento de Erros*:

sql
DELIMITER //

CREATE PROCEDURE sp_AdicionarLivro(IN titulo VARCHAR(255), IN editoraID INT, IN anoPublicacao INT, IN numPaginas INT, IN categoriaID INT, OUT mensagem VARCHAR(255))
BEGIN
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        SET mensagem = 'Erro: Título de livro já existe.';
    END;

    INSERT INTO Livro (Titulo, Editora_ID, Ano_Publicacao, Numero_Paginas, Categoria_ID)
    VALUES (titulo, editoraID, anoPublicacao, numPaginas, categoriaID);

    SET mensagem = 'Livro adicionado com sucesso.';
END //

DELIMITER ;


8. *Autor Mais Antigo*:

sql
DELIMITER //

CREATE PROCEDURE sp_AutorMaisAntigo(OUT autorMaisAntigo VARCHAR(255))
BEGIN
    SELECT CONCAT(Nome, ' ', Sobrenome) INTO autorMaisAntigo
    FROM Autor
    WHERE Data_Nascimento = (SELECT MIN(Data_Nascimento) FROM Autor);
END //

DELIMITER ;

CALL sp_AutorMaisAntigo(@autorMaisAntigo);
SELECT @autorMaisAntigo AS 'Autor Mais Antigo';

CALL sp_AdicionarLivro('Novo Livro', 1, 2023, 250, 2, @mensagem);
SELECT @mensagem AS 'Mensagem';


