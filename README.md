# Neural-Decoder

This code was created by M.Tonutti, P.Denning, and J. Kim as part of the requirements for the Brain-Machine Interfaces course at Imperial College London, Department of Bioengineering.

The monkeydata_training.mat file contains a series of neural spikes obtained from monkeys performing a centre-out task. The aim of the program is to continuously decode the movements of the monkey's arm from this neural information.

*Abstract:* Spinal cord injuries and other types of trauma can result in complete or partial paralysis for the patient; however, neural function often remains working. Decoding algorithms can be used to obtain and use neural information from the motor cortex in order to assist patients with paralysis, for example to control prosthetic devices. In this paper a fully functional decoder for continuous position estimation is built, making use of a linear regression algorithm and k-nearest neighbours classification. Data had previously been obtained from monkeys performing a centre-out task with targets appearing at 8 different angles. With a set of training data of 98 units and 800 trials, our decoder successfully predicted the intended direction of the movement, given only neural information, with a confidence of 91±1%, and it predicted the continous trajectory of the monkeys arm with a root mean squared error of 18.2 centimetres. Additionally, a variety of methods of classification (such as Support Vector Machines) and decoding parameters are tested and analysed.

