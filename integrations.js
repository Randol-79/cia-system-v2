const express = require('express');
const router = express.Router();

// Simple in-memory store for integration credentials (dev only)
let integrationCredentials = {};

// Save credentials: POST /api/integrations/credentials
router.post('/credentials', (req, res) => {
  const creds = req.body && req.body.credentials ? req.body.credentials : {};
  integrationCredentials = { ...integrationCredentials, ...creds };
  return res.json({ status: 'ok' });
});

// Get credentials: GET /api/integrations/credentials
router.get('/credentials', (req, res) => {
  return res.json(integrationCredentials);
});

module.exports = router;
