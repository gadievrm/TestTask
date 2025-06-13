import { LightningElement, wire, track, api } from 'lwc';
import getItems from '@salesforce/apex/ItemService.getItems';
import fetchImageUrl from '@salesforce/apex/UnsplashService.fetchImageUrl';
import getAccountById from '@salesforce/apex/AccountService.getAccountById';
import { createRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import IS_MANAGER_FIELD from '@salesforce/schema/User.IsManager__c';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createPurchase from '@salesforce/apex/PurchaseService.createPurchase';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

export default class ItemPurchaseTool extends NavigationMixin(LightningElement) {



    @api recordId; // здесь можно поставить заглушку
    @track items = [];
    @track filteredItems = [];
    @track cartItems = [];
    @track selectedItem = null;

    accountName;
    accountNumber;
    accountIndustry;

    isModalOpen = false;
    isCartOpen = false;
    isManager = false;

    name = '';
    description = '';
    type = '';
    family = '';
    price = '';

    filterFamily = '';
    filterType = '';
    searchTerm = '';

    familyOptions = [
        { label: 'All', value: '' },
        { label: 'Electronics', value: 'Electronics' },
        { label: 'Books', value: 'Books' },
        { label: 'Furniture', value: 'Furniture' },
        { label: 'Clothing', value: 'Clothing' }
    ];

    typeOptions = [
        { label: 'All', value: '' },
        { label: 'New', value: 'New' },
        { label: 'Used', value: 'Used' },
        { label: 'Refurbished', value: 'Refurbished' }
    ];

    cartColumns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Price (USD)', fieldName: 'Price__c', type: 'currency' },
        {
            type: 'button',
            typeAttributes: {
                label: 'Remove',
                name: 'remove',
                title: 'Remove',
                variant: 'destructive',
                iconPosition: 'left'
            }
        }
    ];

    @wire(CurrentPageReference)
    getPageRef(pageRef) {
        if (pageRef && pageRef.state && pageRef.state.c__accountId) {
            this.recordId = pageRef.state.c__accountId;
        }
    }

    @wire(getItems)
    wiredItems({ data, error }) {
        if (data) {
            this.items = data;
            this.filteredItems = data;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [IS_MANAGER_FIELD] })
    wiredUser({ data }) {
        if (data) {
            this.isManager = data.fields.IsManager__c.value;
        }
    }

    @wire(getAccountById, { accountId: '$recordId' })
    wiredAccount({ data, error }) {
        if (data) {
            this.accountName = data.Name;
            this.accountNumber = data.AccountNumber;
            this.accountIndustry = data.Industry;
        } else if (error) {
            console.error('Account error:', error);
        }
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;
    }

    handleFilterChange(event) {
        const fieldName = event.target.name;
        const value = event.detail.value;

        if (fieldName === 'family') {
            this.filterFamily = value;
        } else if (fieldName === 'type') {
            this.filterType = value;
        }

        this.applyFilters();
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        this.applyFilters();
    }

    applyFilters() {
        this.filteredItems = this.items.filter(item => {
            const matchesFamily = !this.filterFamily || item.Family__c === this.filterFamily;
            const matchesType = !this.filterType || item.Type__c === this.filterType;
            const matchesSearch =
                !this.searchTerm ||
                item.Name.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
                (item.Description__c && item.Description__c.toLowerCase().includes(this.searchTerm.toLowerCase()));
            return matchesFamily && matchesType && matchesSearch;
        });
    }

    async createItem() {
        try {
            const imageUrl = await fetchImageUrl({ query: this.name });

            const fields = {
                Name: this.name,
                Description__c: this.description,
                Type__c: this.type,
                Family__c: this.family,
                Price__c: parseFloat(this.price),
                Image__c: imageUrl
            };

            const recordInput = { apiName: 'Item__c', fields };
            await createRecord(recordInput);

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Item created!',
                variant: 'success'
            }));

            this.closeModal();
            location.reload(); // временно
        } catch (error) {
            console.error(error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Failed to create item.',
                variant: 'error'
            }));
        }
    }

    addToCart(event) {
        const itemId = event.target.dataset.id;
        const item = this.items.find(i => i.Id === itemId);

        if (!this.cartItems.some(i => i.Id === itemId)) {
            this.cartItems = [...this.cartItems, item];

            this.dispatchEvent(new ShowToastEvent({
                title: 'Added to Cart',
                message: `${item.Name} added to cart.`,
                variant: 'success'
            }));
        } else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Already in Cart',
                message: `${item.Name} is already in cart.`,
                variant: 'warning'
            }));
        }
    }

    openCart() {
        this.isCartOpen = true;
    }

    closeCart() {
        this.isCartOpen = false;
    }

    handleCartRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'remove') {
            this.cartItems = this.cartItems.filter(item => item.Id !== row.Id);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Removed from Cart',
                message: `${row.Name} removed from cart.`,
                variant: 'info'
            }));
        }
    }

    handleShowDetails(event) {
        const itemId = event.target.dataset.id;
        this.selectedItem = this.items.find(i => i.Id === itemId);
    }

    closeDetails() {
        this.selectedItem = null;
    }

    async checkout() {
        try {
            const itemIds = this.cartItems.map(i => i.Id);

            const purchaseId = await createPurchase({
                accountId: this.recordId,
                itemIds: itemIds
            });

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Purchase created!',
                variant: 'success'
            }));

            this.cartItems = [];
            this.isCartOpen = false;

            // redirect
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: purchaseId,
                    objectApiName: 'Purchase__c',
                    actionName: 'view'
                }
            });
        } catch (error) {
            console.error(error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Failed to create purchase.',
                variant: 'error'
            }));
        }
    }

}
