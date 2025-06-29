<template>
  <AppLayout>
    <div class="container-fluid">
      <h1 class="h3 mb-4">Interest Group Admin Registration</h1>
      
      <div class="row">
        <div class="col-12 col-lg-8">
          <div class="card">
            <div class="card-header">
              <h5 class="card-title mb-0">Register New IGA</h5>
            </div>
            <div class="card-body">
              <form @submit.prevent="handleSubmit">
                <div class="row g-3">
                  <div class="col-12 col-md-6">
                    <label class="form-label">First Name</label>
                    <input
                      v-model="form.firstName"
                      type="text"
                      class="form-control"
                      required
                    >
                  </div>
                  <div class="col-12 col-md-6">
                    <label class="form-label">Last Name</label>
                    <input
                      v-model="form.lastName"
                      type="text"
                      class="form-control"
                      required
                    >
                  </div>
                  <div class="col-12">
                    <label class="form-label">Email</label>
                    <input
                      v-model="form.email"
                      type="email"
                      class="form-control"
                      required
                    >
                  </div>
                  <div class="col-12">
                    <label class="form-label">Phone</label>
                    <input
                      v-model="form.phone"
                      type="tel"
                      class="form-control"
                      required
                    >
                  </div>
                  <div class="col-12">
                    <label class="form-label">Interest Group</label>
                    <select
                      v-model="form.group"
                      class="form-select"
                      required
                    >
                      <option value="">Select a group</option>
                      <option value="sports">Sports & Fitness</option>
                      <option value="arts">Arts & Culture</option>
                      <option value="tech">Technology</option>
                      <option value="social">Social Activities</option>
                    </select>
                  </div>
                  <div class="col-12">
                    <label class="form-label">Experience</label>
                    <textarea
                      v-model="form.experience"
                      class="form-control"
                      rows="3"
                      placeholder="Describe your experience in managing groups..."
                      required
                    ></textarea>
                  </div>
                  <div class="col-12">
                    <div class="form-check">
                      <input
                        v-model="form.terms"
                        type="checkbox"
                        class="form-check-input"
                        id="terms"
                        required
                      >
                      <label class="form-check-label" for="terms">
                        I agree to the terms and conditions
                      </label>
                    </div>
                  </div>
                </div>
                
                <hr class="my-4">
                
                <div class="d-flex justify-content-end gap-2">
                  <button type="button" class="btn btn-secondary" @click="resetForm">
                    Reset
                  </button>
                  <button type="submit" class="btn btn-success" :disabled="submitting">
                    <span v-if="submitting" class="spinner-border spinner-border-sm me-2"></span>
                    Register IGA
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
        
        <div class="col-12 col-lg-4">
          <!-- Guidelines -->
          <div class="card">
            <div class="card-header">
              <h6 class="mb-0">Registration Guidelines</h6>
            </div>
            <div class="card-body">
              <ul class="mb-0">
                <li>Must be 18 years or older</li>
                <li>Previous experience in group management preferred</li>
                <li>Commitment to organize regular activities</li>
                <li>Background verification will be conducted</li>
                <li>Training will be provided after approval</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref } from 'vue'
import AppLayout from '@/components/common/AppLayout.vue'
import { useToast } from 'vue-toast-notification'

const toast = useToast()
const submitting = ref(false)

const form = ref({
  firstName: '',
  lastName: '',
  email: '',
  phone: '',
  group: '',
  experience: '',
  terms: false
})

const resetForm = () => {
  form.value = {
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    group: '',
    experience: '',
    terms: false
  }
}

const handleSubmit = async () => {
  submitting.value = true
  
  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1500))
    
    toast.success('IGA registration submitted successfully!')
    resetForm()
  } catch (error) {
    toast.error('Failed to submit registration')
  } finally {
    submitting.value = false
  }
}
</script>