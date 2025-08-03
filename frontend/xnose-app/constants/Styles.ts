import { StyleSheet } from 'react-native';

export const GlobalStyles = StyleSheet.create({
  // Estilos para headers consistentes
  screenHeader: {
    alignItems: 'center',
    padding: 20,
    paddingTop: 50, // Espacio para evitar la barra de estado
    paddingBottom: 20,
    borderBottomWidth: 1,
  },
  
  screenTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  
  screenSubtitle: {
    fontSize: 16,
    textAlign: 'center',
    lineHeight: 22,
    opacity: 0.8,
  },
  
  // Contenedores principales
  mainContainer: {
    flex: 1,
  },
  
  scrollContainer: {
    flexGrow: 1,
  },
  
  contentContainer: {
    padding: 20,
    paddingBottom: 80,
  },
  
  // Formularios
  formContainer: {
    borderRadius: 12,
    padding: 24,
    marginTop: 10,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 5,
  },
  
  inputContainer: {
    marginBottom: 24,
  },
  
  inputLabel: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
  },
  
  input: {
    borderWidth: 1,
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
  },
  
  textArea: {
    height: 100,
    paddingTop: 12,
  },
  
  // Botones
  primaryButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 30,
    paddingVertical: 16,
    borderRadius: 12,
    gap: 10,
  },
  
  primaryButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  
  secondaryButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    borderRadius: 12,
    paddingHorizontal: 30,
    paddingVertical: 16,
    gap: 10,
  },
  
  secondaryButtonText: {
    fontSize: 16,
    fontWeight: '600',
  },
  
  buttonIcon: {
    fontSize: 20,
  },
  
  // Pickers
  pickerContainer: {
    borderWidth: 1,
    borderRadius: 8,
  },
  
  picker: {
    height: 50,
    color: '#1f2937',
  },
  
  // Espaciado - usar directamente en los componentes
  
  // Sombras
  cardShadow: {
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 5,
  },
}); 