const fs = require('fs');

const path = 'src/components/shared/ClientFormModal.tsx';
let content = fs.readFileSync(path, 'utf8');

// Update validate function
const validateSearch = `    function validate(): boolean {
      const errs: string[] = [];
      if (fullName.trim().length < 2) errs.push("Name must be at least 2 characters");
      if (!isEdit) {
        if (!email.match(/^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/)) errs.push("Invalid email address");
        if (password.length < 8) errs.push("Password must be at least 8 characters");
      }
      setErrors(errs);
      return errs.length === 0;
    }`;

const validateReplace = `    function validate(): boolean {
      const errs: string[] = [];
      if (fullName.trim().length < 2) errs.push("Name must be at least 2 characters");
      if (!classification) errs.push("Please select a client classification.");
      if (!isEdit) {
        if (!email.match(/^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/)) errs.push("Invalid email address");
        if (password.length < 8) errs.push("Password must be at least 8 characters");
      }
      setErrors(errs);
      return errs.length === 0;
    }`;

content = content.replace(validateSearch, validateReplace);

// Update handleSubmit
const submitSearch = `      if (isEdit && client) {
        updateClient(
          { id: client.id, data: { full_name: fullName, phone: phone || undefined, status } },
          { onSuccess: () => onClose() }
        );
      } else {
        createClient(
          { full_name: fullName, email, password, phone: phone || undefined },
          { onSuccess: () => onClose() }
        );
      }`;

const submitReplace = `      if (isEdit && client) {
        updateClient(
          { id: client.id, data: { full_name: fullName, phone: phone || undefined, status, classification } },
          { onSuccess: () => onClose() }
        );
      } else {
        createClient(
          { full_name: fullName, email, password, phone: phone || undefined, classification },
          { onSuccess: () => onClose() }
        );
      }`;

content = content.replace(submitSearch, submitReplace);

// I already added the dropdown in UI previously before restart!
// Let's verify if the UI still has the classification dropdown.

fs.writeFileSync(path, content);
console.log("Patched validate and submit");
