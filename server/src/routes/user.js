const express = require('express');
const { run, get } = require('../db');
const { authenticateToken } = require('../auth');

const router = express.Router();

// Catalogue of Predefined Stylized Avatars
const PREDEFINED_AVATARS = [
  {
    id: 'boy_1',
    gender: 'boy',
    name: 'Kai (Academic)',
    assetPath: 'assets/avatars/boy_1.png',
    description: 'Messy spiky hair, wireframe glasses, cozy sweater vest.',
    style: 'Lofi Scholar',
  },
  {
    id: 'boy_2',
    gender: 'boy',
    name: 'Ren (Neo Street)',
    assetPath: 'assets/avatars/boy_2.png',
    description: 'Wavy brown hair, confident smirk, cyberpunk bomber jacket.',
    style: 'Cyber Streetwear',
  },
  {
    id: 'boy_3',
    gender: 'boy',
    name: 'Aiden (Techwear)',
    assetPath: 'assets/avatars/boy_3.png',
    description: 'Platinum undercut, cybernetic earpiece, high-collar shell.',
    style: 'Quantum Techwear',
  },
  {
    id: 'boy_4',
    gender: 'boy',
    name: 'Leo (Retro Chill)',
    assetPath: 'assets/avatars/boy_4.png',
    description: 'Curly dark hair, retro sunglasses, relaxed oversized hoodie.',
    style: 'Retro Vibe',
  },
  {
    id: 'girl_1',
    gender: 'girl',
    name: 'Maya (Architect)',
    assetPath: 'assets/avatars/girl_1.png',
    description: 'Sharp dark bob with chic bangs, cat-eye glasses, emerald knit.',
    style: 'Minimalist Chic',
  },
  {
    id: 'girl_2',
    gender: 'girl',
    name: 'Zara (Velocity)',
    assetPath: 'assets/avatars/girl_2.png',
    description: 'Flowing auburn hair, energetic smile, audio headset, neon windbreaker.',
    style: 'Speed & Sound',
  },
  {
    id: 'girl_3',
    gender: 'girl',
    name: 'Yuki (Sentinel)',
    assetPath: 'assets/avatars/girl_3.png',
    description: 'High braided ponytail, sharp focused gaze, cyber ear cuff, black turtleneck.',
    style: 'Sovereign Enclave',
  },
  {
    id: 'girl_4',
    gender: 'girl',
    name: 'Chloe (Lumina)',
    assetPath: 'assets/avatars/girl_4.png',
    description: 'Lilac pixie cut, gentle smile, oversized structured blazer.',
    style: 'High Fashion',
  },
];

// 1. GET PROFILE
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const user = await get(
      `SELECT id, email, full_name, avatar_url, phone_number, bio, tier, is_verified, is_profile_completed, created_at
       FROM users WHERE id = ?`,
      [req.user.userId]
    );

    if (!user) {
      return res.status(404).json({ status: 'error', message: 'User profile not found.' });
    }

    res.json({
      status: 'success',
      profile: {
        id: user.id,
        email: user.email,
        fullName: user.full_name,
        avatarUrl: user.avatar_url,
        phoneNumber: user.phone_number || '',
        bio: user.bio || '',
        tier: user.tier,
        isVerified: user.is_verified === 1,
        isProfileCompleted: user.is_profile_completed === 1,
        createdAt: user.created_at,
      },
    });
  } catch (err) {
    console.error('Fetch profile error:', err);
    res.status(500).json({ status: 'error', message: 'Failed to retrieve profile data.' });
  }
});

// 2. UPDATE PROFILE
router.put('/profile', authenticateToken, async (req, res) => {
  try {
    const { fullName, avatarUrl, phoneNumber, bio } = req.body;

    if (!fullName || fullName.trim().length === 0) {
      return res.status(400).json({ status: 'error', message: 'Full name cannot be empty.' });
    }

    // Verify avatarUrl is valid predefined or fallback
    const validAvatar = avatarUrl || 'assets/avatars/boy_1.png';

    await run(
      `UPDATE users
       SET full_name = ?, avatar_url = ?, phone_number = ?, bio = ?, is_profile_completed = 1, updated_at = datetime('now')
       WHERE id = ?`,
      [fullName.trim(), validAvatar, (phoneNumber || '').trim(), (bio || '').trim(), req.user.userId]
    );

    const updatedUser = await get(
      `SELECT id, email, full_name, avatar_url, phone_number, bio, tier, is_verified, is_profile_completed
       FROM users WHERE id = ?`,
      [req.user.userId]
    );

    res.json({
      status: 'success',
      message: 'Profile updated successfully.',
      profile: {
        id: updatedUser.id,
        email: updatedUser.email,
        fullName: updatedUser.full_name,
        avatarUrl: updatedUser.avatar_url,
        phoneNumber: updatedUser.phone_number,
        bio: updatedUser.bio,
        tier: updatedUser.tier,
        isVerified: updatedUser.is_verified === 1,
        isProfileCompleted: updatedUser.is_profile_completed === 1,
      },
    });
  } catch (err) {
    console.error('Update profile error:', err);
    res.status(500).json({ status: 'error', message: 'Failed to update user profile.' });
  }
});

// 3. GET PREDEFINED AVATARS
router.get('/avatars', (req, res) => {
  res.json({
    status: 'success',
    avatars: PREDEFINED_AVATARS,
  });
});

module.exports = {
  router,
  PREDEFINED_AVATARS,
};
