import mongoose from 'mongoose';

const UserSchema = new mongoose.Schema({
  name: String,
  email: {
    type: String,
    required: true,
    unique: true
  },
  imageUrl: String,
  isSeller: {
    type: Boolean,
    default: false
  },
  cartItems: {
    type: Map,
    of: Number,
    default: {}
  }
}, {
  timestamps: true
});

export default mongoose.models.User || mongoose.model('User', UserSchema);