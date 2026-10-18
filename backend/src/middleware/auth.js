import jwt from 'jsonwebtoken';

export const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    let token;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      token = authHeader.split(' ')[1];
    }

    if (token) {
      const secret = process.env.JWT_SECRET || 'fixit_jwt_secret_dev_key_2026_super_secure';
      const decoded = jwt.verify(token, secret);
      req.user = decoded;
      return next();
    }

    // Fallback for dev / header based phone auth
    const customPhone = req.headers['x-user-phone'] || req.query.phone;
    if (customPhone) {
      req.user = { phone: customPhone, role: 'customer' };
      return next();
    }

    return res.status(401).json({
      success: false,
      message: 'Authentication required. Please provide a Bearer token.',
    });
  } catch (err) {
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired authentication token',
      error: err.message,
    });
  }
};

export const optionalAuthMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      const secret = process.env.JWT_SECRET || 'fixit_jwt_secret_dev_key_2026_super_secure';
      req.user = jwt.verify(token, secret);
    } else if (req.headers['x-user-phone'] || req.query.phone) {
      req.user = { phone: req.headers['x-user-phone'] || req.query.phone, role: 'customer' };
    }
  } catch {
    // optional auth - ignore verification failure
  }
  next();
};
