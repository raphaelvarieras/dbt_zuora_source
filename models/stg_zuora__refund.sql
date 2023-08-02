{{ config(enabled=var('zuora__using_refund', true)) }}

with base as (

    select * 
    from {{ ref('stg_zuora__refund_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_zuora__refund_tmp')),
                staging_columns=get_refund_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as refund_id,
        accounting_code,
        amount,
        cancelled_on,
        comment,
        created_by_id,
        created_date,
        method_type,
        payment_method_id,
        refund_date,
        refund_number,
        refund_transaction_time, 
        settled_on, 
        source_type,
        status,
        submitted_on,
        transferred_to_accounting,
        type,
        updated_by_id,
        updated_date,
        row_number() over (partition by id order by updated_date desc) = 1 as is_most_recent_record
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
