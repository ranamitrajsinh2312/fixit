import express from 'express';
import jwt from 'jsonwebtoken';
import mongoose from 'mongoose';
import { User } from '../models/index.js';
import { authMiddleware } from '../middleware/auth.js';

export const authRouter = express.Router();

// In-memory OTP storage for validation
const otpStore = new Map();

/**
 * POST /api/auth/send-otp
 * Body: { phone }
 */
authRouter.post('/send-otp', async (req, res, next) => {
  try {
    const { phone } = req.body;
    if (!phone) {
      return res.status(400).json({ success: false, message: 'Phone number is required' });
    }

    const cleanPhone = phone.trim();
    // Default demo OTP is 123456; or generate 6-digit OTP
    const otp = cleanPhone === '+91 98795 43210' || process.env.NODE_ENV !== 'production' ? '123456' : Math.floor(100000 + Math.random() * 900000).toString();
    
    otpStore.set(cleanPhone, {
      otp,
      expiresAt: Date.now() + 10 * 60 * 1000, // 10 minutes expiry
    });

    res.json({
      success: true,
      message: `OTP sent successfully to ${cleanPhone}`,
      // Returned for easy testing and development
      otp,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /api/auth/verify-otp
 * Body: { phone, otp, name, city }
 */
authRouter.post('/verify-otp', async (req, res, next) => {
  try {
    const { phone, otp, name, city } = req.body;
    if (!phone || !otp) {
      return res.status(400).json({ success: false, message: 'Phone and OTP are required' });
    }

    const cleanPhone = phone.trim();
    const stored = otpStore.get(cleanPhone);

    // Validate OTP (allow 123456 as master test OTP or match stored)
    const isValid = otp === '123456' || (stored && stored.otp === otp && stored.expiresAt > Date.now());
    if (!isValid) {
      return res.status(400).json({ success: false, message: 'Invalid or expired OTP. Try 123456.' });
    }

    // Clear OTP after use
    otpStore.delete(cleanPhone);

    // Find or create User (with offline fallback if DB not connected)
    let user;
    if (mongoose.connection.readyState === 1) {
      user = await User.findOne({ phone: cleanPhone });
      if (!user) {
        user = await User.create({
          name: name || 'FixIt Customer',
          phone: cleanPhone,
          role: 'customer',
          city: city || 'Rajkot',
          savedAddresses: [
            { tag: 'Home', address: 'Flat 402, Radhe Residency, 150ft Ring Road', isDefault: true },
          ],
        });
      }
    } else {
      user = {
        _id: 'usr_dev_mock',
        name: name || 'Devang Patel',
        phone: cleanPhone,
        role: 'customer',
        city: city || 'Rajkot',
        savedAddresses: [
          { tag: 'Home', address: 'Flat 402, Radhe Residency, 150ft Ring Road', isDefault: true },
        ],
      };
    }

    // Generate JWT
    const secret = process.env.JWT_SECRET || 'fixit_jwt_secret_dev_key_2026_super_secure';
    const token = jwt.sign(
      {
        userId: user._id,
        phone: user.phone,
        role: user.role,
        name: user.name,
      },
      secret,
      { expiresIn: '30d' }
    );

    res.json({
      success: true,
      message: 'Authentication successful',
      token,
      user,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/auth/me
 * Headers: Authorization: Bearer <token>
 */
authRouter.get('/me', authMiddleware, async (req, res, next) => {
  try {
    const phone = req.user?.phone;
    let user;
    if (mongoose.connection.readyState === 1) {
      user = await User.findOne({ phone });
    } else {
      user = {
        _id: req.user?.userId || 'usr_dev_mock',
        name: req.user?.name || 'Devang Patel',
        phone: phone || '+91 98795 43210',
        role: req.user?.role || 'customer',
        city: 'Rajkot',
      };
    }
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    res.json({ success: true, user });
  } catch (err) {
    next(err);
  }
});
