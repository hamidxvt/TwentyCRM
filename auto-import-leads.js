#!/usr/bin/env node

/**
 * Auto-import leads to Twenty CRM
 * Continuously watches for new leads from your source and imports them
 * 
 * Usage: node auto-import-leads.js [source]
 * Sources: csv, api, webhook, salesforce
 */

const fs = require('fs');
const path = require('path');

// Configuration
const TWENTY_API = process.env.TWENTY_API_URL || 'http://localhost:3000/graphql';
const API_TOKEN = process.env.TWENTY_API_TOKEN;

if (!API_TOKEN) {
  console.error('❌ Error: TWENTY_API_TOKEN not set');
  console.error('Set it: export TWENTY_API_TOKEN=your_token');
  process.exit(1);
}

// GraphQL mutation to create person
const CREATE_PERSON_MUTATION = `
  mutation CreatePerson($input: PersonInput!) {
    createPerson(input: $input) {
      id
      email
      firstName
      lastName
    }
  }
`;

// Import from CSV
async function importFromCSV(filePath) {
  console.log(`📂 Reading ${filePath}...`);
  
  const csv = fs.readFileSync(filePath, 'utf-8');
  const lines = csv.trim().split('\n');
  const headers = lines[0].split(',').map(h => h.trim());
  
  let imported = 0;
  
  for (let i = 1; i < lines.length; i++) {
    const values = lines[i].split(',').map(v => v.trim());
    const lead = {};
    
    headers.forEach((header, idx) => {
      lead[header] = values[idx];
    });
    
    if (lead.email) {
      await importLead(lead);
      imported++;
    }
  }
  
  console.log(`✅ Imported ${imported} leads`);
}

// Import single lead
async function importLead(lead) {
  try {
    const response = await fetch(TWENTY_API, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${API_TOKEN}`
      },
      body: JSON.stringify({
        query: CREATE_PERSON_MUTATION,
        variables: {
          input: {
            firstName: lead.firstName || lead.name?.split(' ')[0] || 'Unknown',
            lastName: lead.lastName || lead.name?.split(' ')[1] || '',
            email: lead.email,
            companyName: lead.company || '',
            position: lead.title || lead.position || ''
          }
        }
      })
    });
    
    const data = await response.json();
    
    if (data.errors) {
      console.log(`⚠️  Lead ${lead.email}: ${data.errors[0].message}`);
    } else {
      console.log(`✅ ${lead.email} imported`);
    }
  } catch (error) {
    console.error(`❌ Error importing ${lead.email}:`, error.message);
  }
}

// API webhook listener
async function startWebhookListener(port = 3001) {
  const express = require('express');
  const app = express();
  app.use(express.json());
  
  app.post('/webhook/import-lead', async (req, res) => {
    const lead = req.body;
    await importLead(lead);
    res.json({ success: true });
  });
  
  app.listen(port, () => {
    console.log(`🔗 Webhook listener running on http://localhost:${port}/webhook/import-lead`);
    console.log(`📝 Send POST requests with: { email, firstName, lastName, company, position }`);
  });
}

// Watch CSV file for changes
async function watchCSV(filePath) {
  console.log(`👀 Watching ${filePath} for new leads...`);
  
  let lastCount = 0;
  
  setInterval(async () => {
    if (fs.existsSync(filePath)) {
      const csv = fs.readFileSync(filePath, 'utf-8');
      const lineCount = csv.split('\n').length - 2; // minus header and empty line
      
      if (lineCount > lastCount) {
        console.log(`📥 New leads detected...`);
        await importFromCSV(filePath);
        lastCount = lineCount;
      }
    }
  }, 30000); // Check every 30 seconds
}

// Main
const args = process.argv.slice(2);
const source = args[0] || 'csv';
const filePath = args[1] || './leads.csv';

console.log('🚀 Twenty CRM - Auto Import Tool');
console.log(`📊 Source: ${source}`);
console.log('');

if (source === 'csv') {
  if (!fs.existsSync(filePath)) {
    console.error(`❌ File not found: ${filePath}`);
    process.exit(1);
  }
  
  importFromCSV(filePath).then(() => {
    watchCSV(filePath);
  });
} else if (source === 'webhook') {
  startWebhookListener(3001);
} else {
  console.error(`❌ Unknown source: ${source}`);
  console.error('Supported: csv, webhook');
  process.exit(1);
}
