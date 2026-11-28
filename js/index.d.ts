export interface BirthDate {
  year: number;
  month: number;
  day: number;
}

export type Kind = 'personal' | 'company' | 'vat' | 'iban';

/** The birth date in a personal code, or null when it carries none. */
export function birthDate(code: string): BirthDate | null;
/** Tests a personal code (asmens kodas). */
export function isPersonalCode(code: string): boolean;
/** Tests a company code (juridinio asmens kodas). */
export function isCompanyCode(code: string): boolean;
/** Tests a VAT number (PVM mokėtojo kodas), with or without the LT prefix. */
export function isVatNumber(code: string): boolean;
/** Tests a Lithuanian IBAN. */
export function isIban(code: string): boolean;
/** Lists what a code is valid as; empty when it is valid as nothing. */
export function kinds(code: string): Kind[];
