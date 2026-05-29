
{
  "name": "AI Invoice & Accounting Automation",
  "nodes": [
    {
      "parameters": {
        "pollTimes": {
          "item": [
            {
              "mode": "everyMinute"
            }
          ]
        },
        "simple": false,
        "filters": {
          "q": "is:unread has:attachment",
          "sender": "kishoreagenticai@gmail.com"
        },
        "options": {
          "dataPropertyAttachmentsPrefixName": "Inv",
          "downloadAttachments": true
        }
      },
      "id": "df04b19f-6aee-4dcb-8e50-c326fe952cd6",
      "name": "Gmail Trigger",
      "type": "n8n-nodes-base.gmailTrigger",
      "typeVersion": 1,
      "position": [
        496,
        -448
      ],
      "credentials": {
        "gmailOAuth2": {
          "id": "Acm4CK9Lfh48EQ62",
          "name": "Gmail account"
        }
      }
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://api.ocr.space/parse/image",
        "sendBody": true,
        "contentType": "multipart-form-data",
        "bodyParameters": {
          "parameters": [
            {
              "name": "apikey",
              "value": "K86534563488957"
            },
            {
              "name": "language",
              "value": "eng"
            },
            {
              "parameterType": "formBinaryData",
              "name": "File",
              "inputDataFieldName": "Inv0"
            }
          ]
        },
        "options": {}
      },
      "id": "c82a71b8-3e35-4a94-90a0-50533e7db783",
      "name": "OCR Agent",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4,
      "position": [
        704,
        -448
      ]
    },
    {
      "parameters": {
        "jsCode": "const data = $json;\n\nif (!data.invoice_number) {\n  throw new Error('Invoice number missing');\n}\n\nif (!data.total_amount) {\n  throw new Error('Total amount missing');\n}\n\nreturn [{ json: data }];"
      },
      "id": "33962ef3-70b1-45a3-abe5-6ed2235cdcfd",
      "name": "Validation Agent",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1472,
        -448
      ]
    },
    {
      "parameters": {
        "useCustomSchema": true,
        "tableId": "invoices",
        "fieldsUi": {
          "fieldValues": [
            {
              "fieldId": "vendor_name",
              "fieldValue": "={{ $('Data separation').item.json.vendor_name }}"
            },
            {
              "fieldId": "invoice_number",
              "fieldValue": "={{ $('Data separation').item.json.invoice_number }}"
            },
            {
              "fieldId": "invoice_date",
              "fieldValue": "={{ $('Data separation').item.json.invoice_date }}"
            },
            {
              "fieldId": "total_amount",
              "fieldValue": "={{ $('Data separation').item.json.total_amount }}"
            },
            {
              "fieldId": "gst_amount",
              "fieldValue": "={{ $('Data separation').item.json.tax_amount }}"
            }
          ]
        }
      },
      "id": "d339cf5d-3a6c-4cc0-9ef8-21161bb0be92",
      "name": "Supabase Store",
      "type": "n8n-nodes-base.supabase",
      "typeVersion": 1,
      "position": [
        2176,
        -448
      ],
      "credentials": {
        "supabaseApi": {
          "id": "ImUgsCRwRxkjUYnf",
          "name": "Supabase account"
        }
      }
    },
    {
      "parameters": {
        "sendTo": "kishoreagenticai@gmail.com",
        "subject": "New Invoice Processed",
        "emailType": "text",
        "message": "=📄 New Invoice Processed\n\n🏢 Vendor:\n{{ $('Data separation').item.json.vendor_name }}\n\n💰 Amount:\n₹ {{ $('Data separation').item.json.total_amount }}\n\n📂 Category:\n{{ $('Data Separation from classification agent').item.json.category }}\n\n📅 Invoice Date:\n{{ $('Data separation').item.json.invoice_date }}\n\n🧾 Invoice Number:\n{{ $('Data separation').item.json.invoice_number }}\n\n✅ Status:\nInvoice successfully processed.",
        "options": {}
      },
      "id": "fa332f6c-6fc3-44b2-8b2b-338cff02bb21",
      "name": "Approval Notification",
      "type": "n8n-nodes-base.gmail",
      "typeVersion": 2,
      "position": [
        2432,
        -448
      ],
      "webhookId": "d6f085bd-8b74-449a-8a87-f0c2b5c5b4c9",
      "credentials": {
        "gmailOAuth2": {
          "id": "Acm4CK9Lfh48EQ62",
          "name": "Gmail account"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "const rawText = $json.content.parts[0].text;\n\n// Convert JSON string into object\nconst invoiceData = JSON.parse(rawText);\n\nreturn [\n  {\n    json: {\n      vendor_name: invoiceData.vendor_name || null,\n      vendor_gstin: invoiceData.vendor_gstin || null,\n      invoice_number: invoiceData.invoice_number || null,\n      invoice_date: invoiceData.invoice_date || null,\n      due_date: invoiceData.due_date || null,\n      currency: invoiceData.currency || null,\n      subtotal: Number(invoiceData.subtotal) || 0,\n      cgst: Number(invoiceData.cgst) || 0,\n      sgst: Number(invoiceData.sgst) || 0,\n      igst: Number(invoiceData.igst) || 0,\n      tax_amount: Number(invoiceData.tax_amount) || 0,\n      total_amount:\n        Number(invoiceData.total_amount) ||\n        (\n          Number(invoiceData.subtotal || 0) +\n          Number(invoiceData.tax_amount || 0)\n        ),\n      billing_address: invoiceData.billing_address || null,\n      shipping_address: invoiceData.shipping_address || null,\n      payment_terms: invoiceData.payment_terms || null,\n      line_items: invoiceData.line_items || []\n    }\n  }\n];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1280,
        -448
      ],
      "id": "536fec8a-7275-470f-a026-96aaeece6de3",
      "name": "Data separation"
    },
    {
      "parameters": {
        "modelId": {
          "__rl": true,
          "value": "models/gemini-2.5-flash",
          "mode": "list",
          "cachedResultName": "models/gemini-2.5-flash"
        },
        "messages": {
          "values": [
            {
              "content": "=Classify this invoice:\n\n{{$json}}"
            }
          ]
        },
        "jsonOutput": true,
        "options": {
          "systemMessage": "=You are an accounting classification agent.\n\nClassify the invoice into ONE expense category.\n\nAvailable Categories:\n- Office Supplies\n- Software\n- Travel\n- Marketing\n- Utilities\n- Hardware\n- Food\n- Subscription\n- Maintenance\n- Professional Services\n- Miscellaneous\n\nAnalyze:\n- Vendor name\n- Invoice line items\n- Invoice purpose\n\nReturn ONLY valid JSON:\n\n{\n  \"category\": \"\",\n  \"confidence\": \"\"\n}"
        }
      },
      "type": "@n8n/n8n-nodes-langchain.googleGemini",
      "typeVersion": 1,
      "position": [
        1648,
        -448
      ],
      "id": "3d00f69e-897b-46b9-8d49-92c81c79b6de",
      "name": "Classification Agent",
      "credentials": {
        "googlePalmApi": {
          "id": "gwyCLceu7KlmkwlD",
          "name": "Google Gemini(PaLM) Api account"
        }
      }
    },
    {
      "parameters": {
        "modelId": {
          "__rl": true,
          "value": "models/gemini-2.5-flash",
          "mode": "list",
          "cachedResultName": "models/gemini-2.5-flash"
        },
        "messages": {
          "values": [
            {
              "content": "=Extract invoice details from this OCR text:\n\n{{$json[\"ParsedResults\"][0][\"ParsedText\"]}}"
            }
          ]
        },
        "jsonOutput": true,
        "options": {
          "systemMessage": "=You are an AI invoice extraction agent.  Extract structured invoice details from OCR text.  Return ONLY valid JSON.  Required JSON format:  {   \"vendor_name\": \"\",   \"vendor_gstin\": \"\",   \"invoice_number\": \"\",   \"invoice_date\": \"\",   \"due_date\": \"\",   \"currency\": \"\",   \"subtotal\": \"\",   \"cgst\": \"\",   \"sgst\": \"\",   \"igst\": \"\",   \"tax_amount\": \"\",   \"total_amount\": \"\",   \"billing_address\": \"\",   \"shipping_address\": \"\",   \"payment_terms\": \"\",   \"line_items\": [     {       \"description\": \"\",       \"quantity\": \"\",       \"unit_price\": \"\",       \"amount\": \"\"     }   ] }  Rules: - Convert dates into YYYY-MM-DD format - Remove currency symbols - Return null for missing fields - Do not hallucinate values - Ensure amounts contain only numeric values - Return proper JSON only"
        }
      },
      "type": "@n8n/n8n-nodes-langchain.googleGemini",
      "typeVersion": 1,
      "position": [
        928,
        -448
      ],
      "id": "a56381f3-1a3d-4f82-8ce5-99da13e9503c",
      "name": "Invoice Extraction Agent",
      "credentials": {
        "googlePalmApi": {
          "id": "gwyCLceu7KlmkwlD",
          "name": "Google Gemini(PaLM) Api account"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "const rawText = $json.content.parts[0].text;\n\n// Convert JSON string into object\nconst classificationData = JSON.parse(rawText);\n\nreturn [\n  {\n    json: {\n      category: classificationData.category || null,\n      confidence: classificationData.confidence || null\n    }\n  }\n];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1968,
        -448
      ],
      "id": "1caf5178-cf8a-46e4-b44a-e621d651e075",
      "name": "Data Separation from classification agent"
    },
    {
      "parameters": {
        "operation": "markAsRead",
        "messageId": "={{ $('Gmail Trigger').item.json.id }}"
      },
      "type": "n8n-nodes-base.gmail",
      "typeVersion": 2.2,
      "position": [
        2640,
        -448
      ],
      "id": "0a074862-c0b5-4afb-a640-ef2552b1ca8d",
      "name": "Mark a message as read",
      "webhookId": "1b0d6e99-8ee7-4680-a548-f74988946cce",
      "credentials": {
        "gmailOAuth2": {
          "id": "Acm4CK9Lfh48EQ62",
          "name": "Gmail account"
        }
      }
    }
  ],
  "pinData": {},
  "connections": {
    "Gmail Trigger": {
      "main": [
        [
          {
            "node": "OCR Agent",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "OCR Agent": {
      "main": [
        [
          {
            "node": "Invoice Extraction Agent",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Validation Agent": {
      "main": [
        [
          {
            "node": "Classification Agent",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Supabase Store": {
      "main": [
        [
          {
            "node": "Approval Notification",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Approval Notification": {
      "main": [
        [
          {
            "node": "Mark a message as read",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Data separation": {
      "main": [
        [
          {
            "node": "Validation Agent",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Classification Agent": {
      "main": [
        [
          {
            "node": "Data Separation from classification agent",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Invoice Extraction Agent": {
      "main": [
        [
          {
            "node": "Data separation",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Data Separation from classification agent": {
      "main": [
        [
          {
            "node": "Supabase Store",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Mark a message as read": {
      "main": [
        []
      ]
    }
  },
  "active": false,
  "settings": {
    "executionOrder": "v1"
  },
  "versionId": "6ce2e1c7-7204-47a6-88b0-5e4cc91a8c9b",
  "meta": {
    "templateCredsSetupCompleted": true,
    "instanceId": "43a0460899b84fd6364c26cb72819a84034bbbe9c71a28f8fb477437a85c8fac"
  },
  "id": "PDoc6E2G3aRLYZQZ",
  "tags": []
}
