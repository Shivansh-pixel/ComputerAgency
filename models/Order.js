import mongoose from 'mongoose';

const OrderSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true
  },
  items: [{
    product: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Product'
    },
    quantity: Number
  }],
  amount: {
    type: Number,
    required: true
  },
  address: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Address',
    required: true
  },
  status: {
    type: String,
    default: 'Order Placed'
  }
}, {
  timestamps: true
});

export default mongoose.models.Order || mongoose.model('Order', OrderSchema);