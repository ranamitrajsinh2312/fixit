import mongoose from 'mongoose';
import { Notification } from '../models/index.js';

// In-memory fallback if MongoDB is not connected in tests
const inMemoryNotifications = [];

export const sendNotification = async ({
  recipientPhone,
  title,
  message,
  type = 'job_alert',
  bookingId,
  fcmToken,
}) => {
  console.log(`🔔 [Notification -> ${recipientPhone}] [${type}] ${title}: ${message}`);

  const item = {
    _id: `notif_${Date.now()}_${Math.floor(Math.random() * 1000)}`,
    recipientPhone,
    title,
    message,
    type,
    bookingId,
    isRead: false,
    createdAt: new Date(),
  };

  if (mongoose.connection.readyState === 1) {
    try {
      const created = await Notification.create({
        recipientPhone,
        title,
        message,
        type,
        bookingId,
      });
      return created;
    } catch (e) {
      console.warn(`[Notification] DB save skipped: ${e.message}`);
    }
  }

  inMemoryNotifications.unshift(item);
  return item;
};

export const getNotificationsByPhone = async (phone) => {
  if (mongoose.connection.readyState === 1) {
    try {
      return await Notification.find({ recipientPhone: phone }).sort({ createdAt: -1 }).limit(50);
    } catch (e) {
      console.warn(`[Notification] DB fetch skipped: ${e.message}`);
    }
  }
  return inMemoryNotifications.filter((n) => n.recipientPhone === phone);
};

export const markNotificationRead = async (id) => {
  if (mongoose.connection.readyState === 1) {
    try {
      return await Notification.findByIdAndUpdate(id, { isRead: true }, { new: true });
    } catch (e) {
      console.warn(`[Notification] DB update skipped: ${e.message}`);
    }
  }
  const found = inMemoryNotifications.find((n) => n._id === id);
  if (found) found.isRead = true;
  return found;
};
