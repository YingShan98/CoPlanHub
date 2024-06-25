const ModalCloser = {
    mounted() {
      this.handleEvent("close_modal", () => {
        this.el.dispatchEvent(new Event("click", { bubbles: true }));
      });
    },
  };

  export default ModalCloser;