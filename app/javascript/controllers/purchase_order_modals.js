// Purchase Order Modal Functionality
document.addEventListener('DOMContentLoaded', function() {
  // Sample data for demonstration (in real app, this would come from the server)
  const purchaseRequestsData = [
    {
      id: 1,
      requester: "John Doe",
      department: "Engineering",
      items: "Electrical Equipment",
      estimated_cost: 50000,
      status: "Pending",
      created_at: "2024-01-15"
    },
    {
      id: 2,
      requester: "Jane Smith",
      department: "Operations",
      items: "Safety Equipment",
      estimated_cost: 25000,
      status: "Approved",
      created_at: "2024-01-14"
    },
    {
      id: 3,
      requester: "Mike Johnson",
      department: "Maintenance",
      items: "Tools and Supplies",
      estimated_cost: 15000,
      status: "Rejected",
      created_at: "2024-01-13"
    }
  ];
  
  // Modal functionality
  let currentRequestId = null;
  
  // Test function to check if modals exist
  window.testModals = function() {
    const viewModal = document.getElementById('viewModal');
    const editModal = document.getElementById('editModal');
    const deleteModal = document.getElementById('deleteModal');
    
    console.log('Modal elements found:', {
      viewModal: viewModal,
      editModal: editModal,
      deleteModal: deleteModal
    });
    
    if (viewModal) {
      console.log('View modal display style:', viewModal.style.display);
      console.log('View modal classes:', viewModal.className);
      console.log('View modal computed style:', window.getComputedStyle(viewModal).display);
    }
    
    alert('Check console for modal element details');
  };
  
  // View Modal Functions
  window.openViewModal = function(requestId) {
    console.log('openViewModal called with ID:', requestId);
    currentRequestId = requestId;
    const request = purchaseRequestsData.find(r => r.id === requestId);
    console.log('Found request:', request);
    if (request) {
      const modal = document.getElementById('viewModal');
      const content = document.getElementById('viewModalContent');
      const approvalButtons = document.getElementById('approvalButtons');
      
      console.log('Modal elements found:', { modal, content, approvalButtons });
      
      if (!modal) {
        console.error('View modal element not found!');
        alert('View modal element not found!');
        return;
      }
      
      // Check modal properties
      console.log('Modal before changes:', {
        display: modal.style.display,
        visibility: modal.style.visibility,
        opacity: modal.style.opacity,
        position: modal.style.position,
        zIndex: modal.style.zIndex,
        classes: modal.className,
        computedStyle: window.getComputedStyle(modal)
      });
      
      // Populate modal content
      content.innerHTML = `
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Request ID</label>
            <p class="text-sm text-gray-900">#${request.id}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
              request.status === 'Pending' ? 'bg-yellow-100 text-yellow-800' :
              request.status === 'Approved' ? 'bg-green-100 text-green-800' :
              'bg-red-100 text-red-800'
            }">${request.status}</span>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Requester</label>
            <p class="text-sm text-gray-900">${request.requester}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Department</label>
            <p class="text-sm text-gray-900">${request.department}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Items</label>
            <p class="text-sm text-gray-900">${request.items}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Estimated Cost</label>
            <p class="text-sm text-gray-900">₱${request.estimated_cost.toLocaleString()}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Created Date</label>
            <p class="text-sm text-gray-900">${request.created_at}</p>
          </div>
        </div>
      `;
      
      // Show approval buttons only for pending requests (simulating approver role)
      if (request.status === 'Pending') {
        approvalButtons.classList.remove('hidden');
      } else {
        approvalButtons.classList.add('hidden');
      }
      
      // Show the modal with multiple approaches
      modal.style.display = 'block';
      modal.style.visibility = 'visible';
      modal.style.opacity = '1';
      
      console.log('Modal after changes:', {
        display: modal.style.display,
        visibility: modal.style.visibility,
        opacity: modal.style.opacity,
        position: modal.style.position,
        zIndex: modal.style.zIndex
      });
      
      // Force a reflow
      modal.offsetHeight;
      
      console.log('Modal should now be visible');
      console.log('Modal display style:', modal.style.display);
      console.log('Modal classes:', modal.className);
      
      // Check if modal is actually visible
      const rect = modal.getBoundingClientRect();
      console.log('Modal bounding rect:', rect);
      console.log('Modal is visible:', rect.width > 0 && rect.height > 0);
    }
  };
  
  window.closeViewModal = function() {
    console.log('closeViewModal called');
    const modal = document.getElementById('viewModal');
    modal.style.display = 'none';
    currentRequestId = null;
  };
  
  // Edit Modal Functions
  window.openEditModal = function(requestId) {
    console.log('openEditModal called with ID:', requestId);
    currentRequestId = requestId;
    const request = purchaseRequestsData.find(r => r.id === requestId);
    if (request) {
      const modal = document.getElementById('editModal');
      
      // Populate form fields
      document.getElementById('editRequester').value = request.requester;
      document.getElementById('editDepartment').value = request.department;
      document.getElementById('editItems').value = request.items;
      document.getElementById('editEstimatedCost').value = request.estimated_cost;
      
      // Show the modal
      modal.style.display = 'block';
      console.log('Edit modal should now be visible');
    }
  };
  
  window.closeEditModal = function() {
    console.log('closeEditModal called');
    const modal = document.getElementById('editModal');
    modal.style.display = 'none';
    currentRequestId = null;
  };
  
  // Delete Modal Functions
  window.openDeleteModal = function(requestId) {
    console.log('openDeleteModal called with ID:', requestId);
    currentRequestId = requestId;
    const modal = document.getElementById('deleteModal');
    modal.style.display = 'block';
    console.log('Delete modal should now be visible');
  };
  
  window.closeDeleteModal = function() {
    console.log('closeDeleteModal called');
    const modal = document.getElementById('deleteModal');
    modal.style.display = 'none';
    currentRequestId = null;
  };
  
  // Action Functions
  window.approveRequest = function() {
    if (currentRequestId) {
      // In a real app, this would make an API call to update the status
      alert(`Purchase Request #${currentRequestId} has been approved!`);
      closeViewModal();
      // Refresh the page or update the UI
      location.reload();
    }
  };
  
  window.disapproveRequest = function() {
    if (currentRequestId) {
      // In a real app, this would make an API call to update the status
      alert(`Purchase Request #${currentRequestId} has been disapproved!`);
      closeViewModal();
      // Refresh the page or update the UI
      location.reload();
    }
  };
  
  window.confirmDelete = function() {
    if (currentRequestId) {
      // In a real app, this would make an API call to delete the request
      alert(`Purchase Request #${currentRequestId} has been deleted!`);
      closeDeleteModal();
      // Refresh the page or update the UI
      location.reload();
    }
  };
  
  // Handle edit form submission
  document.getElementById('editForm')?.addEventListener('submit', function(e) {
    e.preventDefault();
    if (currentRequestId) {
      // In a real app, this would make an API call to update the request
      const formData = {
        requester: document.getElementById('editRequester').value,
        department: document.getElementById('editDepartment').value,
        items: document.getElementById('editItems').value,
        estimated_cost: parseFloat(document.getElementById('editEstimatedCost').value)
      };
      
      alert(`Purchase Request #${currentRequestId} has been updated!`);
      closeEditModal();
      // Refresh the page or update the UI
      location.reload();
    }
  });
  
  // Close modals when clicking outside
  window.addEventListener('click', function(e) {
    const viewModal = document.getElementById('viewModal');
    const editModal = document.getElementById('editModal');
    const deleteModal = document.getElementById('deleteModal');
    
    if (e.target === viewModal) {
      closeViewModal();
    }
    if (e.target === editModal) {
      closeEditModal();
    }
    if (e.target === deleteModal) {
      closeDeleteModal();
    }
  });
  
  console.log('Purchase Order Modals JavaScript loaded successfully!');
});
