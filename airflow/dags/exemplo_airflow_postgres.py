#DAG de exemplo para demonstrar interoperabilidade Airflow <-> Postgres
#Esta DAG cria uma tabela no database analytics e insere dados de exemplo

from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.operators.python import PythonOperator

#Config padrão da DAG
default_args = {
    'owner': 'dataeng',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}


def check_connection():
    """Verifica a conexão com o Postgres"""
    hook = PostgresHook(postgres_conn_id='postgres_analytics')
    conn = hook.get_conn()
    cursor = conn.cursor()
    cursor.execute("SELECT version();")
    result = cursor.fetchone()
    print(f"Conexão bem-sucedida! Versão do Postgres: {result[0]}")
    cursor.close()
    conn.close()


def insert_sample_data():
    """Insere dados de exemplo na tabela"""
    hook = PostgresHook(postgres_conn_id='postgres_analytics')
    conn = hook.get_conn()
    cursor = conn.cursor()
    
    # Insere alguns dados de exemplo
    cursor.execute("""
        INSERT INTO exemplo_vendas (produto, quantidade, valor, data_venda)
        VALUES 
            ('Produto A', 10, 100.50, CURRENT_DATE),
            ('Produto B', 5, 250.00, CURRENT_DATE),
            ('Produto C', 8, 150.75, CURRENT_DATE);
    """)
    
    conn.commit()
    cursor.close()
    conn.close()
    print("Dados inseridos com sucesso!")


def query_data():
    """Consulta os dados inseridos"""
    hook = PostgresHook(postgres_conn_id='postgres_analytics')
    conn = hook.get_conn()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT produto, quantidade, valor, data_venda 
        FROM exemplo_vendas 
        ORDER BY data_venda DESC 
        LIMIT 10;
    """)
    
    results = cursor.fetchall()
    print("Dados consultados:")
    for row in results:
        print(f"Produto: {row[0]}, Qtd: {row[1]}, Valor: {row[2]}, Data: {row[3]}")
    
    cursor.close()
    conn.close()


# Definição da DAG
with DAG(
    'exemplo_airflow_postgres',
    default_args=default_args,
    description='DAG de exemplo para demonstrar integração Airflow -> Postgres',
    schedule_interval=None,  # Executar manualmente
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=['exemplo', 'postgres', 'analytics'],
) as dag:

    # Task 1: Verificar conexão
    check_conn = PythonOperator(
        task_id='check_connection',
        python_callable=check_connection,
    )

    # Task 2: Criar tabela se não existir
    create_table = PostgresOperator(
        task_id='create_table',
        postgres_conn_id='postgres_analytics',
        sql="""
            CREATE TABLE IF NOT EXISTS exemplo_vendas (
                id SERIAL PRIMARY KEY,
                produto VARCHAR(100) NOT NULL,
                quantidade INTEGER NOT NULL,
                valor DECIMAL(10, 2) NOT NULL,
                data_venda DATE NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """,
    )

    # Task 3: Inserir dados de exemplo
    insert_data = PythonOperator(
        task_id='insert_sample_data',
        python_callable=insert_sample_data,
    )

    # Task 4: Consultar dados
    query = PythonOperator(
        task_id='query_data',
        python_callable=query_data,
    )

    # Definir dependências
    check_conn >> create_table >> insert_data >> query
