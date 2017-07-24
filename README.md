# GWTCLR
This is a Mathematica coding of the geographically weighted temporally correlated logistic regression (GWTCLR) method.
# Authors
Yang Liu and Tommy Tsan-Yuk Lam
# Introduction of GWTCLR
The geographically weighted temporally correlated logistic regression (GWTCLR) model is a natural extension of GWLR model (Fotheringham et al. 2002) for the analysis of binomial spatial and temporal data. It incorporates both spatial and temporal information by introducing the spatio-temporal varying coefficients to the logistic regression model, which accommodates the potential temporal correlation among the observations with flexible choices of correlation structures. For a specific location, we employ local likelihood method (Cai et al. 2000) to maximize a geographically weighted likelihood with weight related to the geographical relationship in the spatial variant part to obtain the raw estimates for the coefficients. In order to include information from the entire time period, we use smoothing method (Fan et al. 1996) to attain the refined estimates for any particular location in the temporal variant part. Using this method, we can attain regression coefficients of other closely related locations at any time within the observation period, and hence a plot of the coefficient over time can be constructed to visualize the temporal variation of the coefficient estimates. To accommodate the potential correlation among the longitudinal data with auto-correlation structure as a special case, the concept of tetrachoric correlation (Lecessie et al. 1994) is adopted in the model.
# Summary of the Mathematica Coding
The coding file is divided into three parts. The first part gives a brief example of the used data set. Data set can be either saved as an XLSX file or directly defined in Mathematica as a matrix form. The second part is the basic code, all functions are established based on this code. The third part provides several functions, these functions can be used to estimate the regression coefficient and its variance.
# R Code for simulation
The coding file is used to produce simulation data described in the paper. The data is saved in the CSV file and should be converted to XLSX file in order to be analyzed in Mathematica.
# Acknowledgements
This project is supported in part by Hong Kong Research Grants Council General Research Fund (17150816).
